# AstraRAG - Agentic RAG Chatbot

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
├── Dockerfile                      # Docker configuration
├── requirements.txt                # Python dependencies
├── .env                            # Environment variables (create from env_template.txt)
├── env_template.txt                # Template for environment variables
└── start.sh                        # Startup script
```

---

## 🔄 How It Works

### 1. **Document Ingestion Phase**
```
Documents in docs_dir/
        ↓
[ingest_docs.py]
        ↓
Split into chunks (1024 tokens, 50-token overlap)
        ↓
Convert to embeddings (HuggingFace)
        ↓
Store in ChromaDB (doc_vector_store/)
```

### 2. **Query Processing Phase**
```
User Question
        ↓
Frontend (Streamlit) → Backend API (FastAPI)
        ↓
CrewAI Agent + RAG Tool
        ↓
Retrieve similar documents from ChromaDB
        ↓
Generate answer using Groq LLM
        ↓
Return answer + sources + reasoning
        ↓
Display in Frontend
```

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

## 📚 Key Components

### Document Ingestion (`ingest_docs.py`)
- Reads documents from `docs_dir/`
- Parses documents into chunks (1024 tokens, 50-token overlap)
- Generates HuggingFace embeddings
- Stores in ChromaDB vector database

### RAG Tool (`rag_qa_tool.py`)
- CrewAI tool for document retrieval and QA
- Takes a query and returns:
  - Generated answer
  - List of source file names
- Uses top-3 similar document chunks for context

### CrewAI Agent & Task
- **Agent**: Question Answer Agent - specialized in answering user queries
- **Task**: Question Answer Task - retrieves relevant documents and generates responses
- Uses RAG tool for information retrieval

### Backend API (`backend_src/`)
- FastAPI application with `/chat` endpoint
- Accepts chat history and user query
- Calls CrewAI crew for processing
- Returns answer, sources, tool used, and reasoning

### Frontend UI (`frontend_src/`)
- Streamlit-based conversational interface
- Displays chat history with source attribution
- Shows tool used and reasoning in expandable sections
- Real-time streaming of responses

---

## 📊 Dependencies

Key packages used:

| Package | Purpose |
|---------|---------|
| `crewai` | Multi-agent orchestration |
| `fastapi` | Backend API framework |
| `streamlit` | Frontend UI framework |
| `chromadb` | Vector database |
| `llama-index` | Document indexing & RAG |
| `groq` | LLM inference |
| `huggingface` | Embeddings |
| `pydantic` | Data validation |

See `requirements.txt` for complete list and versions.

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

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing documentation
- Review troubleshooting section

---

## 🎓 Learn More

- [CrewAI Documentation](https://docs.crewai.com/)
- [LlamaIndex Documentation](https://docs.llamaindex.ai/)
- [ChromaDB Documentation](https://docs.trychroma.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Streamlit Documentation](https://docs.streamlit.io/)

---

**Built with ❤️ using CrewAI, LlamaIndex, and RAG**
