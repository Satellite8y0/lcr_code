import re
import os
import requests
from openai import OpenAI  # DeepSeek 兼容 OpenAI 客户端

# ======================== 1. 定义智能体系统指令 ========================
AGENT_SYSTEM_PROMPT = """
你是一个智能旅行助手。你的任务是分析用户的请求，并使用可用工具一步步地解决问题。

# 可用工具:
- `get_weather(city: str)`: 查询指定城市的实时天气。
- `get_attraction(city: str, weather: str)`: 根据城市和天气搜索推荐的旅游景点。

# 行动格式:
你的回答必须严格遵循以下格式。首先是你的思考过程，然后是你要执行的具体行动，每次回复只输出一对Thought-Action：
Thought: [这里是你的思考过程和下一步计划]
Action: [这里是你要调用的工具，格式为 function_name(arg_name="arg_value")]

# 任务完成:
当你收集到足够的信息，能够回答用户的最终问题时，你必须在`Action:`字段后使用 `finish(answer="...")` 来输出最终答案。

请开始吧！
"""


# ======================== 2. 定义工具函数 ========================
def get_weather(city: str) -> str:
    """通过调用 wttr.in API 查询真实的天气信息。"""
    url = f"https://wttr.in/{city}?format=j1"
    try:
        response = requests.get(url)
        response.raise_for_status()  # 检查请求是否成功
        data = response.json()
        current_condition = data['current_condition'][0]
        weather_desc = current_condition['weatherDesc'][0]['value']
        temp_c = current_condition['temp_C']
        return f"{city}当前天气:{weather_desc}，气温{temp_c}摄氏度"
    except requests.exceptions.RequestException as e:
        return f"错误:查询天气时遇到网络问题 - {e}"
    except (KeyError, IndexError) as e:
        return f"错误:解析天气数据失败，可能是城市名称无效 - {e}"


def get_attraction(city: str, weather: str) -> str:
    """根据城市和天气，使用Tavily Search API搜索并返回优化后的景点推荐。"""
    api_key = os.environ.get("TAVILY_API_KEY")
    if not api_key:
        return "错误:未配置TAVILY_API_KEY环境变量。"
    from tavily import TavilyClient  # 延迟导入，避免未安装时报错
    tavily = TavilyClient(api_key=api_key)
    query = f"'{city}' 在'{weather}'天气下最值得去的旅游景点推荐及理由"
    try:
        response = tavily.search(query=query, search_depth="basic", include_answer=True)
        if response.get("answer"):
            return response["answer"]
        # 若无综合回答，格式化原始搜索结果
        formatted_results = [f"- {r['title']}: {r['content']}" for r in response.get("results", [])]
        return "根据搜索，为您找到以下信息:\n" + "\n".join(
            formatted_results) if formatted_results else "抱歉，没有找到相关的旅游景点推荐。"
    except Exception as e:
        return f"错误:执行Tavily搜索时出现问题 - {e}"


# 工具字典整合
available_tools = {
    "get_weather": get_weather,
    "get_attraction": get_attraction,
}


# ======================== 3. 适配 DeepSeek LLM 客户端 ========================
class DeepSeekCompatibleClient:
    """用于调用 DeepSeek API 的客户端（兼容 OpenAI 接口格式）"""

    def __init__(self, model: str, api_key: str):
        self.model = model
        # DeepSeek 的 API Base URL（固定）
        self.client = OpenAI(api_key=api_key, base_url="https://api.deepseek.com/v1")

    def generate(self, prompt: str, system_prompt: str) -> str:
        """调用 DeepSeek API 生成回应"""
        print("正在调用 DeepSeek 大语言模型...")
        try:
            messages = [
                {'role': 'system', 'content': system_prompt},
                {'role': 'user', 'content': prompt}
            ]
            response = self.client.chat.completions.create(
                model=self.model,
                messages=messages,
                stream=False,
                temperature=0.1,  # 降低随机性，保证工具调用格式稳定
                max_tokens=1000
            )
            print("DeepSeek 模型响应成功。")
            return response.choices[0].message.content
        except Exception as e:
            print(f"调用 DeepSeek API 时发生错误: {e}")
            return "错误:调用语言模型服务时出错。"


# ======================== 4. 智能体主循环 ========================
def agent_loop(user_query: str, system_prompt: str, tools: dict):
    """智能体主循环：感知-思考-行动-观察 闭环"""
    conversation_history = user_query  # 记录对话历史（感知到的信息）
    while True:
        # 1. 思考：调用 LLM 生成 Thought-Action
        llm_response = llm.generate(prompt=conversation_history, system_prompt=system_prompt)
        print(f"\nLLM 输出:\n{llm_response}")

        # 2. 解析行动：提取工具调用或任务完成指令
        tool_match = re.search(r'Action:\s*(\w+)\((.*?)\)', llm_response, re.DOTALL)
        finish_match = re.search(r'finish\(answer="(.*?)"\)', llm_response, re.DOTALL)

        if finish_match:
            # 任务完成：输出最终答案
            final_answer = finish_match.group(1)
            print(f"\n===== 任务完成！=====\n最终回答:\n{final_answer}")
            break
        elif tool_match:
            # 执行工具调用：获取工具名和参数
            tool_name = tool_match.group(1)
            args_str = tool_match.group(2).strip()
            # 解析参数（如 "city":"北京" 转为字典）
            args = {}
            arg_matches = re.findall(r'(\w+)="(.*?)"', args_str)
            for arg_name, arg_value in arg_matches:
                args[arg_name] = arg_value

            # 检查工具是否存在
            if tool_name not in tools:
                error_msg = f"错误：未知工具 '{tool_name}'"
                print(error_msg)
                conversation_history += f"\nObservation: {error_msg}"
                continue

            # 3. 行动：调用工具并获取结果（观察）
            print(f"\n调用工具: {tool_name}，参数: {args}")
            tool_result = tools[tool_name](**args)
            print(f"工具返回结果: {tool_result}")

            # 4. 更新历史：将观察结果加入对话，供下一轮思考使用
            conversation_history += f"\nObservation: {tool_result}"
        else:
            # 格式错误：提示 LLM 按要求输出
            error_msg = "错误：未按指定格式输出Thought-Action，请重新生成。"
            print(error_msg)
            conversation_history += f"\nObservation: {error_msg}"


# ======================== 5. 运行入口 ========================
if __name__ == "__main__":
    # -------------------------- 配置项（请替换为你的实际密钥） --------------------------
    DEEPSEEK_API_KEY = "sk-22b40fd6b95b41bc852590e5977b5c10"  # 从 DeepSeek 控制台获取：https://platform.deepseek.com/
    DEEPSEEK_MODEL = "deepseek-chat"  # DeepSeek 通用对话模型（固定值）
    TAVILY_API_KEY = "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"  # 可选，仅景点推荐功能需要：https://tavily.com/

    # 设置环境变量（供 Tavily 工具使用）
    os.environ['TAVILY_API_KEY'] = TAVILY_API_KEY

    # 实例化 DeepSeek 客户端
    llm = DeepSeekCompatibleClient(
        model=DEEPSEEK_MODEL,
        api_key=DEEPSEEK_API_KEY
    )

    # 启动智能体，处理用户请求
    user_input = "你好，请帮我查询一下今天北京的天气，然后根据天气推荐一个合适的旅游景点。"
    print(f"用户请求：{user_input}")
    agent_loop(
        user_query=user_input,
        system_prompt=AGENT_SYSTEM_PROMPT,
        tools=available_tools
    )