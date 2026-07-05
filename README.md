# Agentic RAG Chatbot

An intelligent conversational AI system that combines **Retrieval-Augmented Generation (RAG)** with **CrewAI agents** to provide accurate, source-aware answers to user queries. The system retrieves relevant information from a document knowledge base and generates responses with full transparency on sources and reasoning.

---

## 🎯 Features

- **Agentic Workflow**: Uses CrewAI framework with specialized agents and tasks for intelligent question-answering
- **RAG-Powered Responses**: Retrieves relevant documents from a vector database before generating answers
- **Source Attribution**: Displays the source files used to generate each answer
- **Transparent AI**: Shows the tool used and reasoning behind each response
- **Full-Stack Application**: Backend API, frontend UI, and document ingestion pipeline
- **Customizable LLM**: Supports Groq API for language model inference
- **Vector Storage**: Uses ChromaDB for efficient document embedding and retrieval
- **HuggingFace Embeddings**: Leverages pre-trained embeddings for document similarity

---

## 🏗️ Project Architecture

### System Overview

The application follows a **modular three-tier architecture** designed for scalability and maintainability:

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (Streamlit)                      │
│            User Interface @ http://localhost:8501            │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP Requests
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   Backend (FastAPI)                          │
│              Chat API @ http://localhost:8000                │
│                    ┌──────────────┐                          │
│                    │ Chat Service │                          │
│                    └──────┬───────┘                          │
└─────────────────────────────┼─────────────────────────────────┘
                              │
                     ┌────────▼────────┐
                     │   CrewAI Crew   │
                     │  ┌────────────┐ │
                     │  │ QA Agent   │ │
                     │  ├────────────┤ │
                     │  │ QA Task    │ │
                     │  ├────────────┤ │
                     │  │ RAG Tool   │ │
                     │  └──────┬─────┘ │
                     └─────────┼───────┘
                               │
                     ┌─────────▼──────────┐
                     │   Vector Database  │
                     │      (ChromaDB)    │
                     └────────────────────┘
```

### Architecture Components

#### **1. Frontend Layer (Streamlit)**
**File**: `src/frontend_src/app.py`

- **Purpose**: User-facing web interface for conversational interactions
- **Features**:
  - Real-time chat interface with message history
  - Source attribution display
  - Expandable tool/reasoning details
  - Session management for context persistence
- **Port**: 8501
- **Configuration**: `src/frontend_src/config/frontend_settings.py`

#### **2. Backend Layer (FastAPI)**
**Files**: `src/backend_src/main.py`, `src/backend_src/api/chat.py`

- **Purpose**: REST API server for chat operations
- **Endpoints**:
  - `GET /` - Health check
  - `POST /chat/answer` - Process user queries and return answers
- **Port**: 8000
- **Configuration**: `src/backend_src/config/backend_settings.py`
- **Services**: `src/backend_src/services/chat.py` (business logic layer)

#### **3. Agent Layer (CrewAI)**
**Directory**: `src/agents_src/`

- **Crew Configuration** (`crew.py`): Orchestrates agents and tasks
- **Question Answer Agent** (`agents/question_answer_agent.py`): Specialized agent for answering queries
- **Question Answer Task** (`tasks/question_answer_task.py`): Defines the task workflow
- **RAG Tool** (`tools/rag_qa_tool.py`): Retrieves documents and generates answers using RAG
- **LLM Configuration** (`llm/`): Manages Groq LLM integration
- **Configuration**: `src/agents_src/config/agent_settings.py`

#### **4. RAG & Vector Store Layer**
**Directories**: `src/rag_doc_ingestion/`, `doc_vector_store/`

- **Document Ingestion** (`ingest_docs.py`):
  - Reads documents from `docs_dir/`
  - Chunks text (1024 tokens, 50-token overlap)
  - Generates HuggingFace embeddings
  - Stores in ChromaDB vector database
  
- **Vector Database** (ChromaDB):
  - Stores document embeddings
  - Enables semantic similarity search
  - Supports fast retrieval of relevant documents
  
- **Configuration**: `src/rag_doc_ingestion/config/doc_ingestion_settings.py`

---

## 📁 Project Structure

```
agentic-rag-chatbot/
├── src/
│   ├── rag_doc_ingestion/          # Document preprocessing & vector store creation
│   │   ├── ingest_docs.py          # Main ingestion pipeline
│   │   └── config/
│   │       └── doc_ingestion_settings.py
│   │
│   ├── agents_src/                 # CrewAI agents & tools
│   │   ├── crew.py                 # Crew definition (agents + tasks)
│   │   ├── check_crew.py           # Crew validation utility
│   │   ├── agents/
│   │   │   └── question_answer_agent.py  # QA agent definition
│   │   ├── tasks/
│   │   │   └── question_answer_task.py   # QA task definition
│   │   ├── tools/
│   │   │   └── rag_qa_tool.py      # RAG query tool for agents
│   │   ├── llm/
│   │   │   ├── get_llm.py
│   │   │   └── llm_configuration.py
│   │   └── config/
│   │       └── agent_settings.py
│   │
│   ├── backend_src/                # FastAPI backend
│   │   ├── main.py                 # FastAPI app setup
│   │   ├── api/
│   │   │   └── chat.py             # Chat endpoint
│   │   ├── services/
│   │   │   └── chat.py             # Chat business logic
│   │   └── config/
│   │       └── backend_settings.py
│   │
│   └── frontend_src/               # Streamlit UI
│       ├── app.py                  # Main frontend application
│       └── config/
│           └── frontend_settings.py
│
├── doc_vector_store/               # ChromaDB vector store (auto-generated)
├── docs_dir/                       # Directory for input documents
├── Dockerfile                      # Multi-stage Docker build
├── requirements.txt                # Python dependencies
├── .env                            # Environment variables (create from env_template.txt)
├── env_template.txt                # Template for environment variables
├── start.sh                        # Startup script
└── README.md                       # This file
```

---

## 🔄 Data Flow & Processing Pipeline

### Query Processing Workflow

```
1. User Input (Streamlit Frontend)
   └─> Text input from user

2. API Request (Frontend → Backend)
   └─> POST /chat/answer with user query and chat history

3. Backend Processing (FastAPI)
   └─> Receives request and calls CrewAI crew

4. Agent Execution (CrewAI)
   └─> Question Answer Agent processes query
       └─> Uses Question Answer Task
           └─> Calls RAG Tool

5. RAG Retrieval (Vector Store)
   └─> Query embedding generation (HuggingFace)
   └─> Semantic similarity search (ChromaDB)
   └─> Retrieve top-3 similar document chunks

6. LLM Processing (Groq API)
   └─> Generate answer based on retrieved documents
   └─> Include source attribution
   └─> Include reasoning explanation

7. Response Return (Backend → Frontend)
   └─> Answer, sources, tool info, and reasoning

8. Display (Streamlit Frontend)
   └─> Show answer in chat
   └─> Display source files
   └─> Show expandable tool/reasoning details
```

### Document Ingestion Pipeline

```
Input Documents (docs_dir/)
   │
   ├─ PDF, TXT, DOCX formats
   │
   ▼
Document Parsing & Chunking
   │
   ├─ Split into 1024-token chunks
   ├─ 50-token overlap between chunks
   ├─ Preserve metadata (source file, chunk position)
   │
   ▼
Embedding Generation (HuggingFace)
   │
   ├─ Convert text chunks to dense vectors
   ├─ 768-dimensional embeddings
   │
   ▼
Vector Store (ChromaDB)
   │
   ├─ Store embeddings with metadata
   ├─ Index for semantic search
   ├─ Location: doc_vector_store/
   │
   ▼
Ready for Retrieval
```

---

## 📦 Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Streamlit | Interactive web UI |
| **Backend** | FastAPI, Uvicorn | REST API server |
| **AI/ML** | CrewAI | Multi-agent orchestration |
| **Retrieval** | LlamaIndex, ChromaDB | Document indexing & RAG |
| **Embeddings** | HuggingFace Transformers | Text embeddings |
| **LLM** | Groq API | Language model inference |
| **Data Validation** | Pydantic | Configuration & type safety |
| **Environment** | Python 3.11, Docker | Runtime environment |

---

## 🚀 Getting Started

### Prerequisites
- Python 3.8+
- Groq API key (for LLM)
- (Optional) Docker for containerized deployment

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd agentic-rag-chatbot
   ```

2. **Create virtual environment**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   ```bash
   cp env_template.txt .env
   # Edit .env with your configuration:
   # - GROQ_API_KEY: Your Groq API key
   # - MODEL_NAME: LLM model (e.g., 'mixtral-8x7b-32768')
   # - Other settings as needed
   ```

5. **Prepare documents**
   - Place your documents in the `docs_dir/` directory (PDF, TXT, DOCX formats supported)

6. **Ingest documents**
   ```bash
   python -m src.rag_doc_ingestion.ingest_docs
   ```

---

## 🏃 Running the Application

### Option 1: Run All Services (Recommended)
```bash
./start.sh
```

### Option 2: Run Individually

**Backend API:**
```bash
python -m src.backend_src.main
# Runs on http://localhost:8000
```

**Frontend UI:**
```bash
streamlit run src/frontend_src/app.py
# Runs on http://localhost:8501
```

### Option 3: Docker Deployment
```bash
docker build -t agentic-rag-chatbot .
docker run -p 8000:8000 -p 8501:8501 --env-file .env agentic-rag-chatbot
```

---

## 🔧 Configuration

### Environment Variables (.env)

```env
# LLM Configuration
GROQ_API_KEY=your_api_key_here
MODEL_NAME=mixtral-8x7b-32768
MODEL_TEMPERATURE=0.7

# Vector Store Configuration
DOCUMENTS_DIR=./docs_dir
VECTOR_STORE_DIR=./doc_vector_store
COLLECTION_NAME=documents

# Backend Configuration
API_HOST=0.0.0.0
API_PORT=8000

# Frontend Configuration
CHAT_ENDPOINT_URL=http://localhost:8000/chat
```

---

## 📊 Dependencies

Key packages used:

| Package | Version | Purpose |
|---------|---------|---------|
| `crewai` | 0.186.1 | Multi-agent orchestration |
| `fastapi` | 0.116.1 | Backend API framework |
| `streamlit` | 1.49.1 | Frontend UI framework |
| `chromadb` | 1.0.21 | Vector database |
| `llama-index` | 0.14.0 | Document indexing & RAG |
| `llama-index-embeddings-huggingface` | 0.6.1 | HuggingFace embeddings |
| `llama-index-llms-groq` | 0.4.1 | Groq LLM integration |
| `pydantic` | 2.11.9 | Data validation |

See `requirements.txt` for complete list.

---

## 📚 API Documentation

### Health Check
```http
GET /
```

### Chat Endpoint
```http
POST /chat/answer
Content-Type: application/json

{
    "query": "Your question here",
    "chat_history": [...]
}

Response:
{
    "answer": "Generated answer",
    "sources": ["document1.pdf", "document2.txt"],
    "tool_used": "rag_qa_tool",
    "reasoning": "Why this answer was generated"
}
```

---

## 🔐 Security & Best Practices

- **Environment Variables**: Store sensitive data (.env) not in version control
- **API Keys**: Never commit API keys; use .env files
- **CORS**: Configure CORS appropriately for production
- **Rate Limiting**: Consider adding rate limiting for API endpoints
- **Authentication**: Add authentication layer for production use

---

## 🐛 Troubleshooting

### Issue: "Vector store not found"
- **Solution**: Run document ingestion first: `python -m src.rag_doc_ingestion.ingest_docs`

### Issue: "GROQ_API_KEY not found"
- **Solution**: Ensure `.env` file exists and contains valid `GROQ_API_KEY`

### Issue: "No embeddings model"
- **Solution**: First run will download HuggingFace embeddings (~2-3 GB); ensure internet connection

### Issue: Frontend can't connect to API
- **Solution**: Verify `CHAT_ENDPOINT_URL` in `.env` matches backend running address

---

## 📝 Example Usage

1. **Start Backend & Frontend**
   ```bash
   ./start.sh
   ```

2. **Open Frontend**
   - Navigate to `http://localhost:8501`

3. **Ask a Question**
   - Type: "What is machine learning?"
   - The chatbot retrieves relevant documents and generates an answer with sources

4. **View Details**
   - Expand "Show details" to see which tool was used and the reasoning

---

## 🎓 Learn More

- [CrewAI Documentation](https://docs.crewai.com/)
- [LlamaIndex Documentation](https://docs.llamaindex.ai/)
- [ChromaDB Documentation](https://docs.trychroma.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Streamlit Documentation](https://docs.streamlit.io/)

---

**Built with ❤️ using CrewAI, LlamaIndex, and RAG**


# Project Demo

## Home Page & Chatbot Response

<img width="1915" height="951" alt="RAG chatbot" src="https://github.com/user-attachments/assets/a66b4f46-c5f8-4b44-a2f4-5c9cfcbdd234" />

---

## Document Ingestion

<img width="1512" height="467" alt="vector build" src="https://github.com/user-attachments/assets/2bd75741-c3e3-4b35-ae5e-533acd876c2a" />

---

## Docker ps

<img width="1917" height="381" alt="docker ps" src="https://github.com/user-attachments/assets/ba5fbc94-2d03-427d-9f53-4e19ee863f51" />


---

## FastAPI Running

<img width="1897" height="752" alt="fastapi" src="https://github.com/user-attachments/assets/352949ca-5e25-4eea-97e2-e9d2b01b1826" />


---

## AWS EC2 Deployment

<img width="1732" height="645" alt="ec21" src="https://github.com/user-attachments/assets/233952ec-6fc6-43e5-8b2f-1eb8bd1e12e1" />

