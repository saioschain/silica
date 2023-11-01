#!/bin/bash
# 这是一个 Bash 脚本的开头，声明了脚本需要使用的 shell

CHAINID="${CHAIN_ID:-sai_6800-1}"
# 设置 CHAINID 变量，如果环境变量 CHAIN_ID 未设置，则使用 'sai_6800-1' 作为默认值
# 设置链ID变量，如果环境变量 CHAIN_ID 没有被设置，那么将使用 'sai_6800-1' 作为默认值
MONIKER="localtestnet"
# 设置 MONIKER 变量，用于定义节点的名称
# 设置节点的名字为 "localtestnet"
# 请记得在暴露给外部世界时更改为其他类型的 keyring，如 'file'，
# 否则你的余额将会很快被清空
# keyring 测试不需要私钥就可以从你那里窃取代币
KEYRING="test"
# 设置 KEYRING 变量为 "test"，这是一个存储密钥的轻量级选项，主要用于测试目的
# 设置密钥环为 "test"，这是一种不安全的设置，主要用于测试目的
KEYALGO="eth_secp256k1"
# 设置 KEYALGO 变量，用于定义密钥的算法
# 设置密钥算法为 "eth_secp256k1"
LOGLEVEL="info"
# 设置 LOGLEVEL 变量，用于定义日志的级别
# 设置日志级别为 "info"
# 为 said 实例设置专用的家目录
HOMEDIR="$HOME/.tmp-said"
# 设置 HOMEDIR 变量，用于定义 said 实例的家目录
# 设置 said 实例的家目录为 "$HOME/.tmp-said"
# 用来追踪 evm
#TRACE="--trace"
TRACE=""
# 设置 TRACE 变量，如果需要追踪 EVM，可以将其设置为 "--trace"
# 设置 TRACE 变量为空，如果需要追踪 EVM，可以取消下一行的注释

# 路径变量
CONFIG=$HOMEDIR/config/config.toml
# 设置 CONFIG 变量，用于定义 config.toml 文件的路径
APP_TOML=$HOMEDIR/config/app.toml
# 设置 APP_TOML 变量，用于定义 app.toml 文件的路径
GENESIS=$HOMEDIR/config/genesis.json
# 设置 GENESIS 变量，用于定义 genesis.json 文件的路径
TMP_GENESIS=$HOMEDIR/config/tmp_genesis.json
# 设置 TMP_GENESIS 变量，用于定义临时 genesis.json 文件的路径

# 验证是否安装了依赖项
command -v jq >/dev/null 2>&1 || {
	# 检查是否安装了 jq 命令，如果没有安装，打印错误信息并退出
	echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"
	exit 1
}

# 设置 -e 选项，用于在发生任何错误时退出脚本（任何非零退出码）
set -e
# 使用 -e 选项来确保在出现第一个错误时退出脚本

# 解析输入的标志
install=true
# 设置 install 变量为 true，表示默认进行安装
overwrite=""
# 设置 overwrite 变量为空，它将用于确定是否覆盖现有配置

while [[ $# -gt 0 ]]; do
	# 循环遍历所有传入的参数
	key="$1"
	case $key in
		-y)
			# 如果传入 -y 标志，表示要覆盖现有配置
			echo "Flag -y passed -> Overwriting the previous chain data."
			overwrite="y"
			shift # 移过标志
			;;
		-n)
			# 如果传入 -n 标志，表示不覆盖现有配置
			echo "Flag -n passed -> Not overwriting the previous chain data."
			overwrite="n"
			shift # 移过标志
			;;
		--no-install)
			# 如果传入 --no-install 标志，表示跳过安装 said 二进制文件
			echo "Flag --no-install passed -> Skipping installation of the said binary."
			install=false
			shift # 移过标志
			;;
		*)
			# 如果传入未知标志，打印错误信息并退出脚本
			echo "Unknown flag passed: $key -> Exiting script!"
			exit 1
			;;
	esac
done

if [[ $install == true ]]; then
	# 如果 install 变量为 true，则（重新）安装守护进程
	make install
fi

# 如果既没有传入 -y 也没有传入 -n 标志，
# 并且找到了现有的本地节点配置，则提示用户
if [[ $overwrite = "" ]]; then
	if [ -d "$HOMEDIR" ]; then
		# 如果 HOMEDIR 目录已存在，提示用户是否要覆盖
		printf "\nAn existing folder at '%s' was found. You can choose to delete this folder and start a new local node with new keys from genesis. When declined, the existing local node is started. \n" "$HOMEDIR"
		echo "Overwrite the existing configuration and start a new local node? [y/n]"
		read -r overwrite
		#overwrite="y"
	else
		# 如果 HOMEDIR 目录不存在，设置 overwrite 为 "y"
		overwrite="y"
	fi
fi



# 如果overwrite设置为Yes，则设置本地节点，否则跳过设置
# 如果overwrite被设置为“y”或者“Y”，那么就进行本地节点的设置，否则就跳过设置步骤
if [[ $overwrite == "y" || $overwrite == "Y" ]]; then
	# 删除之前的文件夹
	# 移除之前的目录
	rm -rf "$HOMEDIR"

	# 设置客户端配置
	# 配置客户端的配置
	said config keyring-backend "$KEYRING" --home "$HOMEDIR"
	said config chain-id "$CHAINID" --home "$HOMEDIR"

	# 设置myKey地址和助记词
	# 设置myKey地址和助记词
	VAL_KEY="mykey"
	VAL_MNEMONIC="gesture inject test cycle original hollow east ridge hen combine junk child bacon zero hope comfort vacuum milk pitch cage oppose unhappy lunar seat"

	# 设置dev0地址和助记词
	# 设置dev0地址和助记词
	USER1_KEY="dev0"
	USER1_MNEMONIC="copper push brief egg scan entry inform record adjust fossil boss egg comic alien upon aspect dry avoid interest fury window hint race symptom"

	# 设置dev1地址和助记词
	# 设置dev1地址和助记词
	USER2_KEY="dev1"
	USER2_MNEMONIC="maximum display century economy unlock van census kite error heart snow filter midnight usage egg venture cash kick motor survey drastic edge muffin visual"

	# 设置dev2地址和助记词
	# 设置dev2地址和助记词
	USER3_KEY="dev2"
	USER3_MNEMONIC="will wear settle write dance topic tape sea glory hotel oppose rebel client problem era video gossip glide during yard balance cancel file rose"

	# 设置dev3地址和助记词
	# 设置dev3地址和助记词
	USER4_KEY="dev3"
	USER4_MNEMONIC="doll midnight silk carpet brush boring pluck office gown inquiry duck chief aim exit gain never tennis crime fragile ship cloud surface exotic patch"

	# 从助记词中导入密钥
	# 从助记词中导入密钥
	echo "$VAL_MNEMONIC" | said keys add "$VAL_KEY" --recover --keyring-backend "$KEYRING" --algo "$KEYALGO" --home "$HOMEDIR"

	# 将验证者地址存储在变量中以便以后使用
	# 把验证者的地址存储到变量中，以备后用
	node_address=$(said keys show -a "$VAL_KEY" --keyring-backend "$KEYRING" --home "$HOMEDIR")

	echo "$USER1_MNEMONIC" | said keys add "$USER1_KEY" --recover --keyring-backend "$KEYRING" --algo "$KEYALGO" --home "$HOMEDIR"
	echo "$USER2_MNEMONIC" | said keys add "$USER2_KEY" --recover --keyring-backend "$KEYRING" --algo "$KEYALGO" --home "$HOMEDIR"
	echo "$USER3_MNEMONIC" | said keys add "$USER3_KEY" --recover --keyring-backend "$KEYRING" --algo "$KEYALGO" --home "$HOMEDIR"
	echo "$USER4_MNEMONIC" | said keys add "$USER4_KEY" --recover --keyring-backend "$KEYRING" --algo "$KEYALGO" --home "$HOMEDIR"

	# 设置Evmos的moniker和chain-id（Moniker可以是任意内容，chain-id必须是一个整数）
	# 为Evmos设置moniker和chain-id（Moniker可以是任何内容，chain-id必须是整数）
	said init $MONIKER -o --chain-id "$CHAINID" --home "$HOMEDIR"

	# 将参数token denominations更改为asai
	# 把参数中的token denominations改成asai
	jq '.app_state["staking"]["params"]["bond_denom"]="asai"' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
	jq '.app_state["crisis"]["constant_fee"]["denom"]="asai"' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
	jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="asai"' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
	# 当升级到cosmos-sdk v0.47时，使用gov.params来编辑存款参数
	# 在升级到cosmos-sdk v0.47时，使用gov.params来编辑存款参数
	jq '.app_state["gov"]["params"]["min_deposit"][0]["denom"]="asai"' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
	jq '.app_state["evm"]["params"]["evm_denom"]="asai"' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
	jq '.app_state["inflation"]["params"]["mint_denom"]="asai"' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

	# 在genesis中设置gas限制
	# 在创世纪中设置gas上限
	jq '.consensus_params["block"]["max_gas"]="10000000"' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

	# 设置认领开始时间
	# 设置赎回开始的时间
	current_date=$(date -u +"%Y-%m-%dT%TZ")
	jq -r --arg current_date "$current_date" '.app_state["claims"]["params"]["airdrop_start_time"]=$current_date' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

	# 为验证器账户设置认领记录
	# 为验证者账户设置赎回记录
	amount_to_claim=10000
	jq -r --arg node_address "$node_address" --arg amount_to_claim "$amount_to_claim" '.app_state["claims"]["claims_records"]=[{"initial_claimable_amount":$amount_to_claim, "actions_completed":[false, false, false, false],"address":$node_address}]' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

	# 设置赎回衰减
	# 设置赎回减少的相关参数
	jq '.app_state["claims"]["params"]["duration_of_decay"]="1000000s"' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
	jq '.app_state["claims"]["params"]["duration_until_decay"]="100000s"' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

	# 赎回模块账户:
	# 赎回模块账户:
	# 0xA61808Fe40fEb8B3433778BBC2ecECCAA47c8c47 || sai15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz
	#jq -r --arg amount_to_claim "$amount_to_claim" '.app_state["bank"]["balances"] += [{"address":"sai15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz","coins":[{"denom":"asai", "amount":$amount_to_claim}]}]' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
	jq -r --arg amount_to_claim "$amount_to_claim" '.app_state["bank"]["balances"] += [{"address":"sai15cvq3ljql6utxseh0zau9m8ve2j8erz8u99kgm","coins":[{"denom":"asai", "amount":$amount_to_claim}]}]' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"
	#jq -r --arg amount_to_claim "$amount_to_claim" '.app_state["bank"]["balances"] += [{"address":"sai1zhm4ckeze4ptalmy9gkzdzvazzp8dfsp8305sk","coins":[{"denom":"asai", "amount":$amount_to_claim}]}]' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

	# 如果传入参数为"pending"
	# 如果传入的参数是"pending"
	if [[ $1 == "pending" ]]; then
		# 如果操作系统类型是darwin (即MacOS)
		# 如果操作系统是darwin (即MacOS)
		if [[ "$OSTYPE" == "darwin"* ]]; then
			# 修改配置文件中的超时时间
			# 调整提案超时时间为30秒
			sed -i '' 's/timeout_propose = "3s"/timeout_propose = "30s"/g' "$CONFIG"
			# 调整提案超时增量为5秒
			sed -i '' 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' "$CONFIG"
			# 调整预投票超时为10秒
			sed -i '' 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' "$CONFIG"
			# 调整预投票超时增量为5秒
			sed -i '' 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' "$CONFIG"
			# 调整预提交超时为10秒
			sed -i '' 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' "$CONFIG"
			# 调整预提交超时增量为5秒
			sed -i '' 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' "$CONFIG"
			# 调整提交超时为150秒
			sed -i '' 's/timeout_commit = "5s"/timeout_commit = "150s"/g' "$CONFIG"
			# 调整广播事务提交超时为150秒
			sed -i '' 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' "$CONFIG"
		else
			# 对于其他操作系统，进行相同的修改
			# 对于其他操作系统，执行相同的超时时间调整
			sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' "$CONFIG"
			sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' "$CONFIG"
			sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' "$CONFIG"
			sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' "$CONFIG"
			sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' "$CONFIG"
			sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' "$CONFIG"
			sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' "$CONFIG"
			sed -i 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' "$CONFIG"
		fi
	fi

	# 开启 Prometheus 指标并为开发节点启用所有 API
	# 对于 macOS 系统
	if [[ "$OSTYPE" == "darwin"* ]]; then
		# 修改配置，将 Prometheus 设置为 true
		sed -i '' 's/prometheus = false/prometheus = true/' "$CONFIG"
		# 修改 Prometheus 保留时间
		sed -i '' 's/prometheus-retention-time = 0/prometheus-retention-time  = 1000000000000/g' "$APP_TOML"
		# 启用相关配置
		sed -i '' 's/enabled = false/enabled = true/g' "$APP_TOML"
		# 启用相关配置
		sed -i '' 's/enable = false/enable = true/g' "$APP_TOML"
		# 默认不启用 memiavl
		# 检查是否存在 [memiavl] 配置，如果存在，则禁用
		grep -q -F '[memiavl]' "$APP_TOML" && sed -i '/\[memiavl\]/,/^\[/ s/enable = true/enable = false/' "$APP_TOML"
	else
		# 对于其他系统
		# 修改配置，将 Prometheus 设置为 true
		sed -i 's/prometheus = false/prometheus = true/' "$CONFIG"
		# 修改 Prometheus 保留时间
		sed -i 's/prometheus-retention-time  = "0"/prometheus-retention-time  = "1000000000000"/g' "$APP_TOML"
		# 启用相关配置
		sed -i 's/enabled = false/enabled = true/g' "$APP_TOML"
		# 启用相关配置
		sed -i 's/enable = false/enable = true/g' "$APP_TOML"

		
		# 打开全局端口 New
		sed -i 's/address = "127.0.0.1:8545"/address = "0.0.0.0:8545"/g' "$APP_TOML"
		sed -i 's/ws-address = "127.0.0.1:8546"/ws-address = "0.0.0.0:8546"/g' "$APP_TOML"
		
		# 打开Tendermint 相关全局端口 New
		sed -i 's|proxy_app = "tcp://127.0.0.1:26658"|proxy_app = "tcp://0.0.0.0:26658"|g' "$CONFIG"
		sed -i 's|laddr = "tcp://127.0.0.1:26657"|laddr = "tcp://0.0.0.0:26657"|g' "$CONFIG"

		# 默认不启用 memiavl
		# 检查是否存在 [memiavl] 配置，如果存在，则禁用
		grep -q -F '[memiavl]' "$APP_TOML" && sed -i '/\[memiavl\]/,/^\[/ s/enable = true/enable = false/' "$APP_TOML"
	fi

	# 修改提案周期以便在本地测试时能在合理的时间内通过
	# 修改最大存款周期
	sed -i.bak 's/"max_deposit_period": "172800s"/"max_deposit_period": "30s"/g' "$GENESIS"
	# 修改投票周期
	sed -i.bak 's/"voting_period": "172800s"/"voting_period": "30s"/g' "$GENESIS"

	# 设置自定义剪枝设置
	# 修改剪枝配置为自定义
	sed -i.bak 's/pruning = "default"/pruning = "custom"/g' "$APP_TOML"
	# 修改保持最近状态的数量
	sed -i.bak 's/pruning-keep-recent = "0"/pruning-keep-recent = "2"/g' "$APP_TOML"
	# 修改剪枝间隔
	sed -i.bak 's/pruning-interval = "0"/pruning-interval = "10"/g' "$APP_TOML"

	# 分配创世账户（使用 cosmos 格式的地址）
	# 为验证人账户分配代币
	said add-genesis-account "$(said keys show "$VAL_KEY" -a --keyring-backend "$KEYRING" --home "$HOMEDIR")" 100000000000000000000000000asai --keyring-backend "$KEYRING" --home "$HOMEDIR"
	# 为用户 1 账户分配代币
	said add-genesis-account "$(said keys show "$USER1_KEY" -a --keyring-backend "$KEYRING" --home "$HOMEDIR")" 1000000000000000000000asai --keyring-backend "$KEYRING" --home "$HOMEDIR"
	# 为用户 2 账户分配代币
	said add-genesis-account "$(said keys show "$USER2_KEY" -a --keyring-backend "$KEYRING" --home "$HOMEDIR")" 1000000000000000000000asai --keyring-backend "$KEYRING" --home "$HOMEDIR"
	# 为用户 3 账户分配代币
	said add-genesis-account "$(said keys show "$USER3_KEY" -a --keyring-backend "$KEYRING" --home "$HOMEDIR")" 1000000000000000000000asai --keyring-backend "$KEYRING" --home "$HOMEDIR"
	# 为用户 4 账户分配代币
	said add-genesis-account "$(said keys show "$USER4_KEY" -a --keyring-backend "$KEYRING" --home "$HOMEDIR")" 1000000000000000000000asai --keyring-backend "$KEYRING" --home "$HOMEDIR"

	# bc 是用来添加这些大数字的，我们有一个验证人账户 (1e26) 和四个 (1e21) 用户账户，加上已经声明的金额 (1e4)
	# 计算总供应量
	total_supply=100004000000000000000010000
	# 使用 jq 设置总供应量
	jq -r --arg total_supply "$total_supply" '.app_state["bank"]["supply"][0]["amount"]=$total_supply' "$GENESIS" >"$TMP_GENESIS" && mv "$TMP_GENESIS" "$GENESIS"

	# 签署创世交易
	# 为验证人创建创世交易
	said gentx "$VAL_KEY" 1000000000000000000000asai --keyring-backend "$KEYRING" --chain-id "$CHAINID" --home "$HOMEDIR"
	## 如果你想在创世时创建多个验证人
	## 1. 回到 `said keys add` 步骤，初始化更多的密钥
	## 2. 回到 `said add-genesis-account` 步骤，为这些账户添加余额
	## 3. 克隆这个 ~/.said home 目录到其他地方，比如 `~/.clonedEvmosd`
	## 4. 在每个克隆的目录中运行 `gentx`
	## 5. 将 `~/.clonedEvmosd/config/gentx/` 下的 `gentx-*` 文件夹复制到原始的 `~/.said/config/gentx`

	# 收集创世交易
	# 收集所有创世交易，并确保它们是正确的
	said collect-gentxs --home "$HOMEDIR"

	# 运行此命令以确保一切工作正常，创世文件设置正确
	# 验证创世文件是否正确
	said validate-genesis --home "$HOMEDIR"

	# 如果第一个参数是 "pending"，输出提示信息
	if [[ $1 == "pending" ]]; then
		# 输出等待第一个区块提交的提示信息
		echo "pending mode is on, please wait for the first block committed."
	fi

fi



# Start the node
said start \
	--metrics "$TRACE" \
	--log_level $LOGLEVEL \
	--minimum-gas-prices=0.0001asai \
	--json-rpc.api eth,txpool,personal,net,debug,web3 \
	--home "$HOMEDIR" \
	--chain-id "$CHAINID"
