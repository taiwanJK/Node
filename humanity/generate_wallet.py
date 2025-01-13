import os
from eth_account import Account


def generate_config(input_file, output_file):
    """生成标准配置文件"""
    if not os.path.exists(input_file):
        print(f"错误：输入文件 {input_file} 不存在！")
        return
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        # 读取每一行
        for line in infile:
            # 以逗号分隔每一行的数据
            parts = line.strip().split(',')
            if len(parts) > 0:
                private_key = parts[1]  # 私钥在第二个位置
                # 根据要求的格式写入输出文件
                outfile.write(f"http://127.0.0.1||||{private_key}\n")


if __name__ == '__main__':
    # 创建钱包并生成文件名
    file_name = input('请输入钱包文件名（例如 1）:')
    file_name_with_extension = file_name + '.txt'

    # 询问需要生成的钱包数量
    n = int(input('请输入需要创建的钱包数：'))

    # 生成钱包并写入文件
    j = 1
    for i in range(n):
        Account.enable_unaudited_hdwallet_features()
        account, mnemonic = Account.create_with_mnemonic()
        num = '第%d个钱包' % j
        print(num)
        line = ('%s,%s,%s,%d' % (account.address,
                                 account.key.hex(), mnemonic, j))  # mnemonic助记词
        print(line)
        j = j + 1
        with open(file_name_with_extension, 'a') as f:
            f.write(line + '\n')

    # 在生成钱包后，调用生成配置文件的函数
    generate_config(file_name_with_extension, file_name + '_demo.txt')
    print(f"配置文件已生成：{file_name}_demo.txt")