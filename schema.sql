PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE COLLATE NOCASE,
  display_name TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  password_salt TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS sessions (
  token_hash TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tenders (
  id TEXT PRIMARY KEY,
  source TEXT NOT NULL DEFAULT 'manual',
  pncp_id TEXT UNIQUE,
  pncp_url TEXT,
  number TEXT,
  buyer_name TEXT NOT NULL DEFAULT '',
  buyer_cnpj TEXT,
  title TEXT NOT NULL DEFAULT '',
  category TEXT,
  object TEXT NOT NULL DEFAULT '',
  state TEXT,
  city TEXT,
  delivery_location TEXT,
  published_at TEXT,
  opening_at TEXT,
  proposal_deadline TEXT,
  estimated_value REAL,
  status TEXT NOT NULL DEFAULT 'encontrado',
  feasibility TEXT DEFAULT 'pendente',
  notes TEXT DEFAULT '',
  document_key TEXT,
  document_name TEXT,
  document_size INTEGER,
  extracted_text TEXT DEFAULT '',
  created_by TEXT REFERENCES users(id),
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_tenders_status ON tenders(status);
CREATE INDEX IF NOT EXISTS idx_tenders_deadline ON tenders(proposal_deadline);
CREATE INDEX IF NOT EXISTS idx_tenders_buyer ON tenders(buyer_name);

CREATE TABLE IF NOT EXISTS companies (
  id TEXT PRIMARY KEY,
  legal_name TEXT NOT NULL,
  trade_name TEXT DEFAULT '',
  cnpj TEXT DEFAULT '',
  source TEXT NOT NULL DEFAULT 'manual',
  source_url TEXT,
  source_contract_title TEXT,
  source_contract_value REAL,
  source_contract_date TEXT,
  source_buyer TEXT,
  state TEXT DEFAULT '',
  city TEXT DEFAULT '',
  products TEXT DEFAULT '',
  service_regions TEXT DEFAULT '',
  contact_name TEXT DEFAULT '',
  phone TEXT DEFAULT '',
  whatsapp TEXT DEFAULT '',
  email TEXT DEFAULT '',
  website TEXT DEFAULT '',
  freight_info TEXT DEFAULT '',
  delivery_time TEXT DEFAULT '',
  capacity TEXT DEFAULT '',
  documents_status TEXT DEFAULT 'nao_verificado',
  verified_at TEXT,
  notes TEXT DEFAULT '',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_companies_cnpj ON companies(cnpj);
CREATE INDEX IF NOT EXISTS idx_companies_name ON companies(legal_name);

CREATE TABLE IF NOT EXISTS clients (
  id TEXT PRIMARY KEY,
  company_name TEXT NOT NULL,
  contact_name TEXT DEFAULT '',
  cnpj TEXT DEFAULT '',
  email TEXT DEFAULT '',
  phone TEXT DEFAULT '',
  whatsapp TEXT DEFAULT '',
  status TEXT NOT NULL DEFAULT 'potencial',
  source TEXT DEFAULT '',
  next_contact_at TEXT,
  notes TEXT DEFAULT '',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_clients_status ON clients(status);

CREATE TABLE IF NOT EXISTS tender_companies (
  id TEXT PRIMARY KEY,
  tender_id TEXT NOT NULL REFERENCES tenders(id) ON DELETE CASCADE,
  company_id TEXT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  match_score INTEGER NOT NULL DEFAULT 0,
  match_reason TEXT DEFAULT '',
  status TEXT NOT NULL DEFAULT 'precisa_confirmar',
  quote_value REAL,
  confirmed_delivery TEXT,
  confirmed_freight TEXT,
  capacity_confirmed TEXT,
  last_contact_at TEXT,
  notes TEXT DEFAULT '',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(tender_id, company_id)
);

CREATE TABLE IF NOT EXISTS activity_log (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id),
  tender_id TEXT REFERENCES tenders(id) ON DELETE CASCADE,
  company_id TEXT REFERENCES companies(id) ON DELETE CASCADE,
  client_id TEXT REFERENCES clients(id) ON DELETE CASCADE,
  activity_type TEXT NOT NULL,
  note TEXT NOT NULL DEFAULT '',
  occurred_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notification_preferences (
  key TEXT PRIMARY KEY,
  enabled INTEGER NOT NULL DEFAULT 1
);
INSERT OR IGNORE INTO notification_preferences(key, enabled) VALUES
 ('new_tender', 1), ('deadline', 1), ('company_reply', 1),
 ('quotation', 1), ('documents', 1), ('logistics', 1), ('client_followup', 1);

CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY,
  kind TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  tender_id TEXT REFERENCES tenders(id) ON DELETE CASCADE,
  read_at TEXT,
  scheduled_key TEXT UNIQUE,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS search_filters (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  keywords TEXT DEFAULT '',
  state TEXT DEFAULT '',
  value_min REAL,
  value_max REAL,
  enabled INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS app_meta (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

INSERT OR IGNORE INTO app_meta(key,value) VALUES ('schema_version','1');
