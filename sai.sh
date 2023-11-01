#初始化链
saiosd init testing --chain-id=sai_6800-1
#在启动链之前，您需要使用密钥环至少一个帐户填充状态
saiosd keys add my_validator  --keyring-backend "test"

#创建本地帐户后，继续在链的创世文件中授予它一些 asaios 代币
#saiosd add-genesis-account my_validator 10000000000asaios

#分配代币并加入 验证器
#saiosd add-genesis-account my_validator 1000000000stake,10000000000asaios --keyring-backend "test"
saiosd add-genesis-account my_validator 10000000000asaios --keyring-backend "test"

#用于生成一个创建验证者并进行自我委托的创世交易
saiosd gentx my_validator 8000000000asaios --keyring-backend "test"

#将自我委托加入到创世文件中去
saiosd collect-gentxs

#检查 创世文件 genesis.json 文件的正确性
saiosd validate-genesis

#启动你的节点
saiosd start

