
# terraformを使ったEKS構築

## 事前準備

### terraform関連

#### tfenvインストール
[tfenv](https://github.com/tfutils/tfenv#installation)

#### terraformインストール
```
# ここでは0.15.5を利用
tfenv install 0.15.5
```

### AWS, k8s関連

#### aws-cliインストール
[aws-cli](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/install-cliv2.html)

#### aws-iam-authenticator(EKSをkubectlで操作するために必要)
[aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

#### kubectlインストール
[kubectl 1.19](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/install-kubectl.html)


## 構築手順

### terraform実行
```
※ 事前にAWSの認証は通しておくこと

cd terraform
# dry runで実行結果確認
terraform plan
# 反映
terraform apply

# 作成されたkubeconfigを利用(すでに別で存在する場合は上書きしないように注意)
cat eks_kubeconfig > ~/.kube/config
```

### aws load balancer controller作成
```
cd manifest/aws-load-balancer-controller
# cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml

# serviceaccount
kubectl apply -f serviceaccount.yaml

# aws-load-balancer-controller
# ※ ${CLUSTER_NAME} をEKSクラスタ名に変更しておく
kubectl apply -f v2_2_0_full.yaml
```

参考情報: 
[AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/)

### ingress作成
```
cd manifest/ingress

# ※ ${YOUR_DOMAIN} を実際にアクセス可能なドメインにしておく
kubectl apply -f deployment.yaml

# apply後しばらくするとalbが自動生成されているのでRoute53との紐付けなどを行う
```

### その他

#### KMSでsecretsを暗号化する場合
EKSのコンソール画面から 設定 > 詳細 > シークレットの暗号化 の有効化を選択してKMSのキーを選ぶ
(KMSのキーはterraformで作成済み)

#### Container Insights でログとパフォーマンスを確認する
以下を実行(CLUSTER_NAME と REGION は適宜置き換え)
```
ClusterName='$CLUSTER_NAME'
LogRegion='$REGION'
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${LogRegion}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f -
```

参考情報:
[前提条件](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/Container-Insights-prerequisites.html)
[クイックスタートアップ](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html)