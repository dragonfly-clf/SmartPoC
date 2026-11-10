import os
from openai import OpenAI

# Any OpenAI-compatible endpoint; configured through environment variables (see .env.example)
client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY", ""),
    base_url=os.environ.get("OPENAI_BASE_URL") or None,
)
