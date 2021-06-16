
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
kubectl apply -f v2_2_0_full.yaml
```

参考情報: 
[AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/)

### ingress作成
```
cd manifest/ingress

kubectl apply -f deployment.yaml
```