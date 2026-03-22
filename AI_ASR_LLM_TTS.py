import whisper
import pyttsx3
import sounddevice as sd
import soundfile as sf
import time
import os
from openai import OpenAI  # 替换原来的 DeepSeekChat 导入

# 设置 ffmpeg 路径环境变量，让 whisper 能够找到它
os.environ["PATH"] += os.pathsep + r"C:\Users\lcr13\ASR\ffmpeg-master-latest-win64-gpl\bin"


# ===================== 配置项（重点改这里！）=====================
# 替换成你自己的DeepSeek API Key
DEEPSEEK_API_KEY = "sk-22b40fd6b95b41bc852590e5977b5c10"  # 【必填】改成你获取的API Key

# 录音参数（不用改）
CHANNELS = 1
RATE = 16000
RECORD_SECONDS = 5
WAVE_OUTPUT_FILENAME = "temp_audio.wav"

# 初始化工具
# 1. 语音转文字（Whisper）
# 指定 download_root 会将下载的 .pt 模型保存在这个文件夹下
whisper_model = whisper.load_model("medium", download_root="whisper_model")  # medium模型，速度快
# 2. 文字转语音（TTS）
tts_engine = pyttsx3.init()
tts_engine.setProperty('rate', 150)  # 语速
tts_engine.setProperty('volume', 1.0)  # 音量
# 3. 初始化DeepSeek客户端
client = OpenAI(
    api_key="sk-22b40fd6b95b41bc852590e5977b5c10",  # 替换为你的Key
    base_url="https://api.deepseek.com"  # 必须指定DeepSeek的API地址
)

# ===================== 核心函数 =====================
# 用于存储对话历史（上下文），实现多轮对话
chat_history = [
    {"role": "system", "content": "你是一个非常有帮助、友善的语音助手。请用简短、口语化的语言回答，适合语音播报。"}
]

def record_audio():
    """录音：录制麦克风声音并保存为wav文件"""
    print("🎤 开始说话（5秒）...")
    # 使用 sounddevice 录制音频
    recording = sd.rec(int(RECORD_SECONDS * RATE), samplerate=RATE, channels=CHANNELS)
    sd.wait()  # 等待录音结束
    print("🎙️ 录音结束！")
    
    # 保存录音文件
    sf.write(WAVE_OUTPUT_FILENAME, recording, RATE)

def audio_to_text(audio_file):
    """语音转文字：Whisper识别录音"""
    # 强制使用 fp32 避免 CPU 警告，并且这也能避免在没有 GPU 时的意外报错
    # 增加 condition_on_previous_text=False 参数来抑制幻觉/重复，提高在嘈杂环境下的稳定性
    result = whisper_model.transcribe(
        audio_file, 
        language="zh", 
        fp16=False,
        condition_on_previous_text=False,  # 抑制模型幻觉，对噪声更鲁棒
        no_speech_threshold=0.6            # 提高静音/噪声过滤的阈值
    )
    text = result["text"].strip()
    print(f"🤖 识别到你说：{text}")
    return text

def get_ai_response(text):
    """调用DeepSeek API生成回答，支持上下文管理"""
    global chat_history
    
    if not text:
        return "我没听清你说什么哦～"
        
    try:
        # 1. 将用户的新问题加入历史记录
        chat_history.append({"role": "user", "content": text})
        
        # 2. 限制上下文长度（比如只保留最近的10轮对话，防止Token超限和API报错）
        # 注意：这里保留了第1条的 system prompt，以及最后的最多 20 条消息（即10轮问答）
        if len(chat_history) > 21:
            chat_history = [chat_history[0]] + chat_history[-20:]

        # 3. 将包含历史记录的整个列表发给 AI
        response = client.chat.completions.create(
            model="deepseek-chat",  # DeepSeek对话模型名
            messages=chat_history,
            temperature=0.7
        )
        
        answer = response.choices[0].message.content
        print(f"🤖 AI回答：{answer}")
        
        # 4. 将 AI 的回答也加入历史记录，完成闭环
        chat_history.append({"role": "assistant", "content": answer})
        
        return answer
    except Exception as e:
        print(f"❌ DeepSeek调用失败：{e}")
        # 如果报错了，就把刚才加进去的用户问题弹出来，避免破坏历史记录结构
        if chat_history[-1]["role"] == "user":
            chat_history.pop()
        return "抱歉，我暂时无法回答你的问题～"

def text_to_audio(text):
    """文字转语音并播放"""
    tts_engine.say(text)
    tts_engine.runAndWait()

# ===================== 主程序 =====================
if __name__ == "__main__":
    print("===== AI语音对话小助手（DeepSeek版） =====")
    print("提示：按回车开始录音，录音5秒后自动识别")
    print("      你可以对麦克风说“再见”、“退出”或“结束”来终止对话。")
    print("      或者在终端输入 'q' 并回车退出。")
    
    while True:
        user_input = input("\n📢 按回车键开始说话（输入q退出）：")
        if user_input.lower() == 'q':
            print("👋 再见！")
            break
            
        # 核心流程：录音 → 转文字 → AI回答 → 播放语音
        try:
            record_audio()
            user_text = audio_to_text(WAVE_OUTPUT_FILENAME)
            
            # --- 语音退出功能 ---
            # 检查用户说的话是否包含退出关键词
            exit_keywords = ["再见", "退出", "结束", "不聊了", "拜拜"]
            if any(keyword in user_text for keyword in exit_keywords):
                goodbye_msg = "好的，那我们下次再聊，拜拜！"
                print(f"🤖 AI回答：{goodbye_msg}")
                text_to_audio(goodbye_msg)
                print("👋 对话已通过语音指令结束。")
                break
            # --------------------
            
            ai_answer = get_ai_response(user_text)
            text_to_audio(ai_answer)
        except Exception as e:
            print(f"❌ 程序出错：{e}")
            text_to_audio("抱歉，运行出错了～")
        time.sleep(1)