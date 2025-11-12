# Google Cloud Generative AI: Complete Overview for AI Agents

## Purpose

This manual provides a comprehensive overview of Google Cloud's generative AI services and how to build production AI applications. It covers **349 official notebooks**, key services, and practical patterns.

**What you'll learn**:
- Complete GCP GenAI service landscape
- When to use each service
- Integration patterns for agents
- Model selection strategies
- Cost and performance optimization

**Repository**: https://github.com/GoogleCloudPlatform/generative-ai (349 notebooks, 413 Python files)

---

## Quick Start (10 Minutes)

```bash
# Install SDK
pip install google-cloud-aiplatform

# Authenticate
gcloud auth application-default login

# Set project
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID

# Enable APIs
gcloud services enable aiplatform.googleapis.com
```

**First Agent**:
```python
import vertexai
from vertexai.generative_models import GenerativeModel

vertexai.init(project=PROJECT_ID, location="us-central1")

model = GenerativeModel("gemini-2.5-flash")
response = model.generate_content("Explain quantum computing in simple terms")
print(response.text)
```

---

## Service Landscape

### 1. Foundation Models (LLMs)

#### Gemini Models (Google)

| Model | Use Case | Context | Speed | Cost |
|-------|----------|---------|-------|------|
| **gemini-2.5-pro** | Complex reasoning, analysis | 1M tokens | Slow | High |
| **gemini-2.5-flash** | General purpose, production | 1M tokens | Fast | Medium |
| **gemini-2.0-flash** | Fast responses, cost-optimized | 32K tokens | Very Fast | Low |
| **gemini-nano-lite** | Edge/mobile devices | 4K tokens | Instant | Very Low |

**Multimodal Support**: Text, images, video, audio, PDF

**Example**:
```python
from vertexai.generative_models import GenerativeModel, Part

model = GenerativeModel("gemini-2.5-pro")

# Text + image
response = model.generate_content([
    "Describe this image in detail:",
    Part.from_uri("gs://bucket/image.jpg", mime_type="image/jpeg"),
])

# Text + video
response = model.generate_content([
    "Summarize this video:",
    Part.from_uri("gs://bucket/video.mp4", mime_type="video/mp4"),
])

# Text + audio
response = model.generate_content([
    "Transcribe and analyze this audio:",
    Part.from_uri("gs://bucket/audio.mp3", mime_type="audio/mpeg"),
])
```

#### Partner Models (via Model Garden)

| Model | Provider | Best For |
|-------|----------|----------|
| **Claude Sonnet 4.5** | Anthropic | Long documents, analysis |
| **Claude Opus 4** | Anthropic | Highest intelligence |
| **Claude Haiku 4** | Anthropic | Speed + cost |
| **Llama 3.x** | Meta | Open source, fine-tuning |
| **Mistral Large** | Mistral | Multilingual |
| **Gemma 2/3** | Google | Open source, edge |

**Accessing Claude on Vertex AI**:
```python
from anthropic import AnthropicVertex

client = AnthropicVertex(
    project_id=PROJECT_ID,
    region="us-east5",  # Claude only in us-east5
)

response = client.messages.create(
    model="claude-sonnet-4-5@20250929",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Explain RAG systems"}],
)

print(response.content[0].text)
```

**LiteLLM Router Pattern** (use multiple models):
```python
import litellm

litellm.vertex_project = PROJECT_ID
litellm.vertex_location = "us-central1"

# Route to different models
gemini_response = litellm.completion(
    model="vertex_ai/gemini-2.5-flash",
    messages=[{"role": "user", "content": "Quick question"}],
)

claude_response = litellm.completion(
    model="vertex_ai/claude-sonnet-4-5@20250929",
    messages=[{"role": "user", "content": "Complex analysis"}],
)
```

### 2. Agent Frameworks

#### Google ADK (Agent Development Kit)

**When to use**: Production agents, multi-agent systems, Google Cloud native

```python
from google.adk.agents import Agent

agent = Agent(
    name="customer_support",
    model="gemini-2.5-flash",
    instruction="You are a helpful customer support agent.",
    tools=[search_orders, update_ticket, send_email],
)

response = agent.send_message("Where is order #12345?")
```

**Key Features**:
- Model-agnostic (Gemini, Claude, Llama)
- Deployment-agnostic (Cloud Run, Agent Engine, local)
- Built-in session management
- Native tool use
- Multi-agent coordination

#### Vertex AI Agent Engine

**When to use**: Managed agent hosting, no infrastructure management

```python
from google.cloud.aiplatform import reasoning_engines

# Deploy agent
deployed_agent = reasoning_engines.ReasoningEngine.create(
    reasoning_engine=agent,
    requirements=["google-cloud-aiplatform"],
    display_name="Support Agent",
)

# Query deployed agent
response = deployed_agent.query(
    input="Where is my order?",
)
```

**Advantages**:
- Serverless (no Docker, no Cloud Run config)
- Auto-scaling
- Session persistence
- Integrated monitoring

#### LangChain / LangGraph

**When to use**: Complex workflows, existing LangChain ecosystem

```python
from langchain_google_vertexai import VertexAI
from langgraph.graph import StateGraph

llm = VertexAI(model_name="gemini-2.5-flash")

# Define graph-based workflow
workflow = StateGraph()
workflow.add_node("research", research_node)
workflow.add_node("analyze", analyze_node)
workflow.add_node("respond", respond_node)

workflow.add_edge("research", "analyze")
workflow.add_edge("analyze", "respond")

app = workflow.compile()
result = app.invoke({"query": "Analyze market trends"})
```

#### CrewAI

**When to use**: Multi-agent collaboration, role-based teams

```python
from crewai import Agent, Task, Crew

engineer = Agent(
    role="Engineer",
    goal="Write high-quality code",
    llm="gemini-2.5-flash",
)

qa = Agent(
    role="QA Engineer",
    goal="Find bugs and security issues",
    llm="gemini-2.5-flash",
)

code_task = Task(description="Implement user auth", agent=engineer)
review_task = Task(description="Review the code", agent=qa)

crew = Crew(agents=[engineer, qa], tasks=[code_task, review_task])
result = crew.kickoff()
```

### 3. RAG & Knowledge Systems

#### Vertex AI Search (Enterprise Search)

**When to use**: Enterprise search, website search, grounding with citations

```python
from google.cloud import discoveryengine_v1 as discoveryengine

client = discoveryengine.SearchServiceClient()

request = discoveryengine.SearchRequest(
    serving_config=f"projects/{PROJECT_ID}/locations/global/collections/default_collection/dataStores/{DATA_STORE_ID}/servingConfigs/default_config",
    query="How do I deploy an agent?",
    page_size=10,
)

response = client.search(request)

for result in response.results:
    print(f"Title: {result.document.derived_struct_data['title']}")
    print(f"Snippet: {result.document.derived_struct_data['snippets'][0]['snippet']}")
    print(f"Link: {result.document.derived_struct_data['link']}")
```

**Features**:
- Full-text + semantic search
- Website crawling
- Structured data support
- Faceted navigation
- Search analytics

#### Vertex AI Vector Search

**When to use**: Similarity search, recommendations, custom embeddings

```python
from google.cloud import aiplatform

# Create index
index = aiplatform.MatchingEngineIndex.create_tree_ah_index(
    display_name="product-embeddings",
    dimensions=768,
    approximate_neighbors_count=150,
    leaf_node_embedding_count=500,
)

# Deploy index
index_endpoint = aiplatform.MatchingEngineIndexEndpoint.create(
    display_name="product-search-endpoint",
)

index_endpoint.deploy_index(
    index=index,
    deployed_index_id="product-search-v1",
)

# Query
response = index_endpoint.find_neighbors(
    deployed_index_id="product-search-v1",
    queries=[query_embedding],
    num_neighbors=10,
)
```

**Features**:
- Billion-scale vector search
- Multiple distance metrics (L2, cosine, dot product)
- Hybrid search (dense + sparse embeddings)
- Real-time updates

#### RAG Engine (Unified RAG Framework)

**When to use**: Quick RAG setup, multiple vector database support

```python
from vertexai.preview import rag

# Create corpus
corpus = rag.create_corpus(display_name="product-docs")

# Import files
rag.import_files(
    corpus_name=corpus.name,
    paths=["gs://bucket/docs/*.pdf"],
    chunk_size=512,
    chunk_overlap=100,
)

# Create retrieval tool
def retrieve_docs(query: str) -> str:
    response = rag.retrieval_query(
        rag_resources=[rag.RagResource(rag_corpus=corpus.name)],
        text=query,
        similarity_top_k=5,
    )
    return "\n\n".join([chunk.text for chunk in response.contexts.contexts])

# Use with agent
agent = Agent(
    name="rag_agent",
    model="gemini-2.5-flash",
    tools=[retrieve_docs],
)
```

**Supported Backends**:
- Vertex AI Vector Search
- Vertex AI Search
- Pinecone
- Weaviate
- Vertex AI Feature Store

### 4. Embeddings

#### Text Embeddings

```python
from vertexai.language_models import TextEmbeddingModel

model = TextEmbeddingModel.from_pretrained("text-embedding-005")

# Single text
embedding = model.get_embeddings(["Hello world"])[0].values

# Batch
texts = ["Query 1", "Query 2", "Query 3"]
embeddings = model.get_embeddings(texts)

# Dimensionality reduction
embedding = model.get_embeddings(
    ["Long text"],
    output_dimensionality=256,  # Reduce from 768 to 256
)[0].values
```

**Models**:
- `text-embedding-005` (768 dims, latest)
- `text-multilingual-embedding-002` (768 dims, 100+ languages)
- `textembedding-gecko@003` (768 dims, legacy)

#### Multimodal Embeddings

```python
from vertexai.vision_models import MultiModalEmbeddingModel

model = MultiModalEmbeddingModel.from_pretrained("multimodalembedding@001")

# Image embedding
image = Image.load_from_file("product.jpg")
embedding = model.get_embeddings(image=image).image_embedding

# Text + image combined
embedding = model.get_embeddings(
    image=image,
    contextual_text="red running shoes",
).image_embedding
```

### 5. Vision & Media Generation

#### Imagen (Image Generation)

```python
from vertexai.preview.vision_models import ImageGenerationModel

model = ImageGenerationModel.from_pretrained("imagen-4.0-flash")

# Generate image
images = model.generate_images(
    prompt="A futuristic city with flying cars at sunset, cyberpunk style",
    number_of_images=4,
    aspect_ratio="16:9",
)

for i, image in enumerate(images):
    image.save(f"generated_{i}.png")

# Edit existing image
edited_images = model.edit_image(
    base_image=Image.load_from_file("original.jpg"),
    mask=Image.load_from_file("mask.png"),  # What to change
    prompt="Replace with modern architecture",
)
```

**Models**:
- `imagen-4.0` (highest quality)
- `imagen-4.0-flash` (faster, cheaper)
- `imagen-3` (previous generation)

#### Veo (Video Generation)

```python
from vertexai.preview.vision_models import VideoGenerationModel

model = VideoGenerationModel.from_pretrained("veo-3")

# Generate video
video = model.generate_video(
    prompt="A dog running through a field of flowers, slow motion, cinematic",
    duration_seconds=5,
    aspect_ratio="16:9",
)

video.save("generated_video.mp4")
```

#### Image Captioning & Analysis

```python
from vertexai.vision_models import MultiModalEmbeddingModel

model = GenerativeModel("gemini-2.5-pro-vision")

# Analyze image
image = Part.from_uri("gs://bucket/product.jpg", mime_type="image/jpeg")
response = model.generate_content([
    "Describe this product in detail. Include colors, materials, and style.",
    image,
])

print(response.text)
```

### 6. Audio & Speech

#### Chirp (Speech-to-Text)

```python
from google.cloud import speech_v2

client = speech_v2.SpeechClient()

# Transcribe audio
config = speech_v2.RecognitionConfig(
    auto_decoding_config=speech_v2.AutoDetectDecodingConfig(),
    language_codes=["en-US"],
    model="chirp",  # Latest model
)

response = client.recognize(
    config=config,
    content=audio_bytes,
)

for result in response.results:
    print(result.alternatives[0].transcript)
```

#### Text-to-Speech (Gemini TTS)

```python
from google.cloud import texttospeech_v1

client = texttospeech_v1.TextToSpeechClient()

response = client.synthesize_speech(
    input=texttospeech_v1.SynthesisInput(text="Hello, how can I help you?"),
    voice=texttospeech_v1.VoiceSelectionParams(
        language_code="en-US",
        name="en-US-Wavenet-D",
    ),
    audio_config=texttospeech_v1.AudioConfig(
        audio_encoding=texttospeech_v1.AudioEncoding.MP3,
    ),
)

with open("output.mp3", "wb") as f:
    f.write(response.audio_content)
```

### 7. Function Calling & Tool Use

```python
from vertexai.generative_models import FunctionDeclaration, Tool

# Define tools
get_weather = FunctionDeclaration(
    name="get_weather",
    description="Get current weather for a location",
    parameters={
        "type": "object",
        "properties": {
            "location": {"type": "string", "description": "City name"},
        },
        "required": ["location"],
    },
)

search_docs = FunctionDeclaration(
    name="search_docs",
    description="Search documentation",
    parameters={
        "type": "object",
        "properties": {
            "query": {"type": "string"},
        },
        "required": ["query"],
    },
)

tool = Tool(function_declarations=[get_weather, search_docs])

# Use with model
model = GenerativeModel("gemini-2.5-flash", tools=[tool])

response = model.generate_content("What's the weather in Tokyo?")

# Extract function call
if response.candidates[0].function_calls:
    function_call = response.candidates[0].function_calls[0]
    print(f"Function: {function_call.name}")
    print(f"Arguments: {function_call.args}")

    # Execute function
    result = execute_function(function_call.name, function_call.args)

    # Send result back
    response = model.generate_content([
        response.candidates[0].content,
        Part.from_function_response(
            name=function_call.name,
            response={"content": result},
        ),
    ])
```

### 8. Grounding

#### Grounding with Google Search

```python
from vertexai.preview.generative_models import GenerativeModel, Tool
from google.cloud.aiplatform_v1beta1.types import GoogleSearchRetrieval

google_search_tool = Tool.from_google_search_retrieval(
    GoogleSearchRetrieval(disable_attribution=False)
)

model = GenerativeModel(
    "gemini-2.5-flash",
    tools=[google_search_tool],
)

response = model.generate_content("What are the latest AI developments in 2025?")

# Response includes grounding metadata
print(response.text)
print(response.candidates[0].grounding_metadata)  # Citations
```

#### Grounding with Vertex AI Search

```python
from vertexai.preview.generative_models import Tool
from google.cloud.aiplatform_v1beta1.types import VertexAISearch

vertex_ai_search_tool = Tool.from_retrieval(
    retrieval=VertexAISearch(datastore=f"projects/{PROJECT_ID}/locations/global/collections/default_collection/dataStores/{DATA_STORE_ID}")
)

model = GenerativeModel(
    "gemini-2.5-flash",
    tools=[vertex_ai_search_tool],
)

response = model.generate_content("How do I deploy to Agent Engine?")
```

### 9. Evaluation & Monitoring

#### Vertex AI Evaluation

```python
from vertexai.evaluation import EvalTask

eval_task = EvalTask(
    dataset="gs://bucket/eval_dataset.jsonl",
    metrics=["bleu", "rouge_l", "coherence", "safety"],
    experiment="agent-eval-v1",
)

eval_result = eval_task.evaluate(
    model=model,
    prompt_template="Answer the question: {question}",
)

print(f"BLEU: {eval_result.summary_metrics['bleu']}")
print(f"Coherence: {eval_result.summary_metrics['coherence']}")
```

#### Cloud Logging & Trace

```python
import logging
from opentelemetry import trace

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

logger.info("Agent query received", extra={"user_id": "123", "query": "..."})

# Tracing
tracer = trace.get_tracer(__name__)

with tracer.start_as_current_span("agent_request") as span:
    span.set_attribute("user_id", "123")
    span.set_attribute("model", "gemini-2.5-flash")

    response = agent.send_message(query)

    span.set_attribute("response_length", len(response))
```

---

## Model Selection Guide

### By Use Case

| Use Case | Recommended Model | Reasoning |
|----------|-------------------|-----------|
| **Chatbot** | gemini-2.5-flash | Fast, cost-effective, good quality |
| **Code generation** | gemini-2.5-pro, claude-sonnet-4-5 | Best reasoning |
| **Long documents** | claude-sonnet-4-5, gemini-2.5-pro | 1M+ token context |
| **Image analysis** | gemini-2.5-pro-vision | Multimodal |
| **Quick responses** | gemini-2.0-flash | Lowest latency |
| **Edge/mobile** | gemini-nano-lite | On-device |
| **Multilingual** | mistral-large, gemini-2.5-flash | Strong multilingual |
| **Cost-sensitive** | gemini-2.0-flash | Lowest cost |

### By Performance Characteristics

| Model | Latency | Cost | Quality | Context |
|-------|---------|------|---------|---------|
| gemini-2.5-pro | Slow | High | Excellent | 1M |
| gemini-2.5-flash | Fast | Medium | Very Good | 1M |
| gemini-2.0-flash | Very Fast | Low | Good | 32K |
| claude-sonnet-4-5 | Moderate | High | Excellent | 200K |
| claude-haiku-4 | Fast | Low | Good | 200K |
| llama-3.1-405b | Slow | Medium | Excellent | 128K |

### Cost Optimization Strategies

#### 1. Use Appropriate Model

```python
# BAD - Using Pro for simple tasks
model = GenerativeModel("gemini-2.5-pro")
response = model.generate_content("What's 2+2?")  # Expensive!

# GOOD - Use Flash for routine tasks
model = GenerativeModel("gemini-2.5-flash")
response = model.generate_content("What's 2+2?")  # 10x cheaper
```

#### 2. Context Caching

```python
from vertexai.preview.caching import CachedContent

# Cache common context (like documentation)
cached_content = CachedContent.create(
    model_name="gemini-2.5-flash",
    system_instruction="You are a support agent for Acme Corp.",
    contents=[documentation_text],  # Large, rarely changing
    ttl="3600s",  # Cache for 1 hour
)

# Reuse cached context
model = GenerativeModel.from_cached_content(cached_content)
response = model.generate_content("How do I reset my password?")
# Subsequent calls use cached context - 75% cost reduction!
```

#### 3. Batch Processing

```python
# BAD - Individual calls
for query in queries:
    response = model.generate_content(query)  # Multiple API calls

# GOOD - Batch
responses = model.generate_content_async(queries)  # Single API call
```

#### 4. Output Token Limits

```python
# Limit output to avoid runaway costs
response = model.generate_content(
    query,
    generation_config={"max_output_tokens": 256},  # Prevent long responses
)
```

---

## Architecture Patterns

### Pattern 1: Simple Agent

```
User Query → Gemini → Response
```

**Use**: Basic chatbots, Q&A

```python
model = GenerativeModel("gemini-2.5-flash")
response = model.generate_content(query)
```

### Pattern 2: Agent with Tools

```
User Query → Agent
    ↓
Reasoning Loop:
├─ Tool 1 (search)
├─ Tool 2 (database)
└─ Tool 3 (API call)
    ↓
Synthesized Response
```

**Use**: Task automation, complex queries

```python
agent = Agent(
    model="gemini-2.5-flash",
    tools=[search_tool, db_tool, api_tool],
)
```

### Pattern 3: RAG Agent

```
User Query
    ↓
Generate Embedding
    ↓
Vector Search
    ↓
Retrieve Context
    ↓
Agent + Context → Grounded Response
```

**Use**: Knowledge-based assistants

```python
retriever = get_vertex_ai_search_retriever()
agent = Agent(
    model="gemini-2.5-flash",
    tools=[retriever],
)
```

### Pattern 4: Multi-Agent

```
User Query → Manager Agent
    ↓
Delegate to:
├─ Research Agent
├─ Code Agent
└─ Data Agent
    ↓
Synthesize Results → Response
```

**Use**: Complex workflows, specialization

```python
manager = Agent(
    model="gemini-2.0-flash",
    tools=[route_to_specialist],
)
```

### Pattern 5: Human-in-the-Loop

```
User Query → Agent → Draft Response
    ↓
Human Review
    ↓
Approved → Final Response
```

**Use**: High-stakes decisions, content moderation

```python
draft = agent.send_message(query)
approved = await human_review(draft)
if approved:
    send_response(draft)
```

---

## Deployment Options

### Option 1: Cloud Run

**When**: Custom backends, full control, containerized apps

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY . .
RUN pip install -r requirements.txt

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
```

```bash
gcloud run deploy agent \
    --source . \
    --region us-central1 \
    --set-env-vars PROJECT_ID=$PROJECT_ID
```

### Option 2: Vertex AI Agent Engine

**When**: Managed hosting, no infrastructure

```python
from google.cloud.aiplatform import reasoning_engines

deployed = reasoning_engines.ReasoningEngine.create(
    reasoning_engine=agent,
    requirements=["google-cloud-aiplatform"],
    display_name="My Agent",
)
```

### Option 3: Cloud Functions

**When**: Event-driven, serverless functions

```python
import functions_framework
from vertexai.generative_models import GenerativeModel

@functions_framework.http
def agent_endpoint(request):
    model = GenerativeModel("gemini-2.5-flash")
    response = model.generate_content(request.json["query"])
    return {"response": response.text}
```

---

## Production Best Practices

### 1. Error Handling

```python
from google.api_core import exceptions, retry

@retry.Retry(predicate=retry.if_exception_type(
    exceptions.ResourceExhausted,
    exceptions.ServiceUnavailable,
))
def call_model(query: str) -> str:
    try:
        response = model.generate_content(query)
        return response.text
    except exceptions.ResourceExhausted:
        # Rate limit - back off
        raise
    except exceptions.InvalidArgument as e:
        # Bad input - don't retry
        logger.error(f"Invalid input: {e}")
        return "Invalid request"
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return "An error occurred"
```

### 2. Rate Limiting

```python
import time
from collections import deque

class RateLimiter:
    def __init__(self, requests_per_minute: int = 60):
        self.requests = deque()
        self.limit = requests_per_minute

    def acquire(self):
        now = time.time()
        # Remove old requests
        while self.requests and self.requests[0] < now - 60:
            self.requests.popleft()

        if len(self.requests) >= self.limit:
            sleep_time = 60 - (now - self.requests[0])
            time.sleep(sleep_time)

        self.requests.append(now)

limiter = RateLimiter(requests_per_minute=60)

def call_model(query: str) -> str:
    limiter.acquire()
    return model.generate_content(query).text
```

### 3. Monitoring

```python
from google.cloud import monitoring_v3
import time

def record_latency(operation: str, duration: float):
    client = monitoring_v3.MetricServiceClient()
    project_name = f"projects/{PROJECT_ID}"

    series = monitoring_v3.TimeSeries()
    series.metric.type = "custom.googleapis.com/agent/latency"
    series.metric.labels["operation"] = operation

    point = monitoring_v3.Point()
    point.value.double_value = duration
    point.interval.end_time.seconds = int(time.time())

    series.points = [point]
    client.create_time_series(name=project_name, time_series=[series])

# Usage
start = time.time()
response = agent.send_message(query)
record_latency("agent_query", time.time() - start)
```

### 4. Security

```python
# Input validation
def validate_input(query: str) -> bool:
    if len(query) > 10000:
        return False
    if contains_injection_attempt(query):
        return False
    return True

# Content filtering
from vertexai.preview.generative_models import HarmCategory, HarmBlockThreshold

model = GenerativeModel(
    "gemini-2.5-flash",
    safety_settings={
        HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
    },
)
```

---

## Common Patterns & Recipes

### Recipe 1: Chatbot with Memory

```python
from google.cloud import firestore

db = firestore.Client()

def get_conversation_history(user_id: str) -> list:
    messages = db.collection("conversations").document(user_id).get()
    return messages.to_dict().get("messages", []) if messages.exists else []

def save_message(user_id: str, role: str, content: str):
    doc_ref = db.collection("conversations").document(user_id)
    doc_ref.set({
        "messages": firestore.ArrayUnion([{"role": role, "content": content}])
    }, merge=True)

def chat(user_id: str, query: str) -> str:
    history = get_conversation_history(user_id)
    save_message(user_id, "user", query)

    # Build conversation
    messages = []
    for msg in history:
        messages.append({"role": msg["role"], "parts": [msg["content"]]})
    messages.append({"role": "user", "parts": [query]})

    model = GenerativeModel("gemini-2.5-flash")
    response = model.generate_content(messages).text

    save_message(user_id, "model", response)
    return response
```

### Recipe 2: Document Q&A with Citations

```python
from vertexai.preview import rag

def document_qa(query: str) -> dict:
    # Retrieve relevant chunks
    response = rag.retrieval_query(
        rag_resources=[rag.RagResource(rag_corpus=corpus.name)],
        text=query,
        similarity_top_k=5,
    )

    # Build context with sources
    context_parts = []
    sources = []
    for i, chunk in enumerate(response.contexts.contexts):
        context_parts.append(f"[{i+1}] {chunk.text}")
        sources.append({
            "id": i+1,
            "file": chunk.source_uri,
            "page": chunk.page_number,
        })

    context = "\n\n".join(context_parts)

    # Generate answer
    prompt = f"""Answer the question using only the provided context.
    Cite sources using [1], [2], etc.

Context:
{context}

Question: {query}

Answer:"""

    model = GenerativeModel("gemini-2.5-flash")
    answer = model.generate_content(prompt).text

    return {"answer": answer, "sources": sources}
```

### Recipe 3: Multi-Step Workflow

```python
from langgraph.graph import StateGraph

def research_step(state):
    query = state["query"]
    research = research_agent.send_message(query)
    state["research"] = research
    return state

def code_step(state):
    code_prompt = f"Based on this research:\n{state['research']}\n\nWrite code to implement it."
    code = code_agent.send_message(code_prompt)
    state["code"] = code
    return state

def review_step(state):
    review_prompt = f"Review this code:\n{state['code']}"
    review = review_agent.send_message(review_prompt)
    state["review"] = review
    return state

# Build workflow
workflow = StateGraph()
workflow.add_node("research", research_step)
workflow.add_node("code", code_step)
workflow.add_node("review", review_step)

workflow.add_edge("research", "code")
workflow.add_edge("code", "review")

app = workflow.compile()

result = app.invoke({"query": "Implement user authentication"})
```

---

## Troubleshooting

### Issue: Rate Limit Errors

```python
# Error: 429 Resource Exhausted
# Solution: Implement retry with exponential backoff

from google.api_core import retry

@retry.Retry(
    initial=1.0,
    maximum=60.0,
    multiplier=2.0,
    predicate=retry.if_exception_type(exceptions.ResourceExhausted),
)
def call_with_retry(query: str) -> str:
    return model.generate_content(query).text
```

### Issue: High Latency

```python
# Problem: Responses taking 10+ seconds
# Solutions:

# 1. Use faster model
model = GenerativeModel("gemini-2.0-flash")  # Instead of Pro

# 2. Reduce output length
generation_config = {"max_output_tokens": 256}

# 3. Use streaming
for chunk in model.generate_content(query, stream=True):
    print(chunk.text, end="")  # Show partial results
```

### Issue: High Costs

```python
# Problem: $1000+ monthly bill
# Solutions:

# 1. Cache common contexts
cached_content = CachedContent.create(...)

# 2. Use cheaper models for simple queries
def route_by_complexity(query: str):
    if is_simple(query):
        return gemini_flash_model.generate_content(query)
    else:
        return gemini_pro_model.generate_content(query)

# 3. Limit context size
def trim_context(docs: list, max_tokens: int = 2000):
    # Only include most relevant docs
    return docs[:5]
```

### Issue: Safety Blocks

```python
# Problem: Content filtered by safety settings
# Solution: Adjust safety thresholds (carefully!)

from vertexai.generative_models import HarmBlockThreshold

model = GenerativeModel(
    "gemini-2.5-flash",
    safety_settings={
        HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
    },
)
```

---

## Learning Resources

### Official Documentation
- Vertex AI: https://cloud.google.com/vertex-ai/docs
- Generative AI on Vertex AI: https://cloud.google.com/vertex-ai/docs/generative-ai/learn/overview
- Model Garden: https://cloud.google.com/vertex-ai/docs/start/explore-models

### Code Examples
- Repository (349 notebooks): https://github.com/GoogleCloudPlatform/generative-ai
- Agent Starter Pack: https://github.com/GoogleCloudPlatform/agent-starter-pack
- ADK Samples: https://github.com/google/adk-samples

### Learning Paths
1. **Beginner**: Start with gemini/getting-started/
2. **Intermediate**: Explore gemini/function-calling/ and rag-engine/
3. **Advanced**: Study gemini/agents/ and workshops/

---

## Summary

### Key Services

| Category | Services | Best For |
|----------|----------|----------|
| **Models** | Gemini, Claude, Llama | Generation, analysis |
| **Agents** | ADK, Agent Engine, LangGraph | Orchestration, workflows |
| **RAG** | Vertex AI Search, Vector Search, RAG Engine | Knowledge systems |
| **Embeddings** | Text/Multimodal embeddings | Semantic search |
| **Vision** | Imagen, Veo, Gemini Vision | Image/video generation |
| **Audio** | Chirp, TTS | Speech processing |
| **Tools** | Function calling, grounding | Tool integration |

### Quick Recommendations

**For most agents**: Use Gemini 2.5 Flash + Vertex AI Search + ADK + Agent Engine

**For complex analysis**: Use Gemini 2.5 Pro or Claude Sonnet 4.5

**For cost optimization**: Use Gemini 2.0 Flash + context caching

**For multimodal**: Use Gemini 2.5 Pro Vision

**For production**: Use Agent Engine (managed) or Cloud Run (custom)

### Next Steps

1. **Try Quick Start**: Get first agent running in 10 minutes
2. **Choose Pattern**: Single-agent, RAG, or multi-agent
3. **Select Services**: Model + RAG + deployment
4. **Build & Deploy**: Use Agent Starter Pack for quick setup
5. **Monitor & Optimize**: Add logging, tracing, cost monitoring

**Total Resources**: 349 notebooks, 100+ models, 6 agent frameworks, 3 deployment options
