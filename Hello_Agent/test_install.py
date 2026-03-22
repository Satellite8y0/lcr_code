# 测试三个核心库是否安装成功
import requests
import tavily
import openai

print("✅ requests 安装成功，版本：", requests.__version__)
print("✅ tavily-python 安装成功")
print("✅ openai 安装成功，版本：", openai.__version__)
print("\n🎉 所有依赖库安装完成！可以开始写Agent项目了！")