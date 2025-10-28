-- ХАБЫ (HUBS) - Таблицы бизнес-ключей
-- Назначение: Хранение уникальных бизнес-ключей сущностей
-- 

-- Хаб: Студенты
CREATE TABLE Hub_Student (
    student_hash_key TEXT PRIMARY KEY,           -- Хэш-ключ студента (MD5 от бизнес-ключа)
    student_id INTEGER NOT NULL,                 -- Бизнес-ключ (исходный ID)
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Дата загрузки записи
    record_source TEXT DEFAULT 'SYSTEM',         -- Источник данных
    UNIQUE(student_id)
);

-- Хаб: Предметы
CREATE TABLE Hub_Subject (
    subject_hash_key TEXT PRIMARY KEY,           -- Хэш-ключ предмета
    subject_id INTEGER NOT NULL,                 -- Бизнес-ключ предмета
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_source TEXT DEFAULT 'SYSTEM',
    UNIQUE(subject_id)
);

-- Хаб: Экзамены
CREATE TABLE Hub_Exam (
    exam_hash_key TEXT PRIMARY KEY,              -- Хэш-ключ экзамена
    exam_id INTEGER NOT NULL,                    -- Бизнес-ключ экзамена
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_source TEXT DEFAULT 'SYSTEM',
    UNIQUE(exam_id)
);

-- Хаб: Темы
CREATE TABLE Hub_Topic (
    topic_hash_key TEXT PRIMARY KEY,             -- Хэш-ключ темы
    topic_id INTEGER NOT NULL,                   -- Бизнес-ключ темы
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_source TEXT DEFAULT 'SYSTEM',
    UNIQUE(topic_id)
);

-- =============================================================================
-- СПУТНИКИ (SATELLITES) - Таблицы описательных атрибутов
-- Назначение: Хранение изменяемых атрибутов сущностей с историей изменений
-- =============================================================================

-- Спутник: Детали студентов
CREATE TABLE Sat_Student_Details (
    student_hash_key TEXT,                       -- Ссылка на хаб студента
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Дата загрузки версии
    hash_diff TEXT,                              -- Хэш различий (для отслеживания изменений)
    name TEXT NOT NULL,                          -- Имя студента
    email TEXT NOT NULL,                         -- Email студента
    level TEXT CHECK(level IN ('бакалавр', 'магистр', 'аспирант')), -- Уровень образования
    effective_date DATE,                         -- Дата начала действия версии
    end_date DATE,                               -- Дата окончания действия версии
    is_current BOOLEAN DEFAULT TRUE,             -- Текущая версия записи
    record_source TEXT DEFAULT 'SYSTEM',
    PRIMARY KEY (student_hash_key, load_date),
    FOREIGN KEY (student_hash_key) REFERENCES Hub_Student(student_hash_key)
);

-- Спутник: Детали предметов
CREATE TABLE Sat_Subject_Details (
    subject_hash_key TEXT,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hash_diff TEXT,
    title TEXT NOT NULL,                         -- Название предмета
    credits INTEGER NOT NULL,                    -- Количество кредитов
    difficulty INTEGER,                          -- Сложность (1-5)
    description TEXT,                            -- Описание предмета
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM',
    PRIMARY KEY (subject_hash_key, load_date),
    FOREIGN KEY (subject_hash_key) REFERENCES Hub_Subject(subject_hash_key)
);

-- Спутник: Детали экзаменов
CREATE TABLE Sat_Exam_Details (
    exam_hash_key TEXT,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hash_diff TEXT,
    exam_date DATE NOT NULL,                     -- Дата проведения экзамена
    max_score INTEGER NOT NULL,                  -- Максимальный балл
    min_excellent_score INTEGER NOT NULL,        -- Минимальный балл для отлично
    description TEXT,                            -- Описание экзамена
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM',
    PRIMARY KEY (exam_hash_key, load_date),
    FOREIGN KEY (exam_hash_key) REFERENCES Hub_Exam(exam_hash_key)
);

-- Спутник: Детали тем
CREATE TABLE Sat_Topic_Details (
    topic_hash_key TEXT,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hash_diff TEXT,
    title TEXT NOT NULL,                         -- Название темы
    hours_required REAL NOT NULL,                -- Необходимое время изучения
    priority INTEGER,                            -- Приоритет темы (1-3)
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM',
    PRIMARY KEY (topic_hash_key, load_date),
    FOREIGN KEY (topic_hash_key) REFERENCES Hub_Topic(topic_hash_key)
);

-- Спутник: Детали ресурсов
CREATE TABLE Sat_Resource_Details (
    resource_hash_key TEXT PRIMARY KEY,          -- Хэш-ключ ресурса
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hash_diff TEXT,
    type TEXT CHECK(type IN ('книга', 'статья', 'видео', 'задачи', 'лекции')),
    title TEXT NOT NULL,                         -- Название ресурса
    url TEXT,                                    -- Ссылка на ресурс
    description TEXT,                            -- Описание ресурса
    quality_rating INTEGER,                      -- Качество ресурса (1-5)
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM'
);

-- Спутник: Детали прогресса изучения
CREATE TABLE Sat_StudyProgress_Details (
    progress_hash_key TEXT PRIMARY KEY,          -- Хэш-ключ прогресса
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hash_diff TEXT,
    understanding_level INTEGER,                 -- Уровень понимания (1-5)
    hours_studied REAL,                          -- Затраченное время
    confidence_level INTEGER,                    -- Уровень уверенности (1-5)
    last_studied DATE,                           -- Дата последнего изучения
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM'
);

-- Спутник: Детали результатов экзаменов
CREATE TABLE Sat_ExamResult_Details (
    result_hash_key TEXT PRIMARY KEY,            -- Хэш-ключ результата
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hash_diff TEXT,
    score INTEGER NOT NULL,                      -- Полученный балл
    grade TEXT,                                  -- Оценка
    preparation_time INTEGER,                    -- Время подготовки
    achieved_excellent BOOLEAN,                  -- Достигнута ли цель "отлично"
    feedback TEXT,                               -- Обратная связь
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM'
);

-- =============================================================================
-- СВЯЗИ (LINKS) - Таблицы бизнес-взаимодействий
-- Назначение: Хранение связей между бизнес-ключами с историей изменений
-- =============================================================================

-- Связь: Студент - Предмет (изучение)
CREATE TABLE Link_Student_Subject (
    link_student_subject_hash_key TEXT PRIMARY KEY, -- Хэш-ключ связи
    student_hash_key TEXT NOT NULL,               -- Ссылка на студента
    subject_hash_key TEXT NOT NULL,               -- Ссылка на предмет
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_date DATE,                          -- Дата начала связи
    end_date DATE,                                -- Дата окончания связи
    is_current BOOLEAN DEFAULT TRUE,              -- Активная связь
    record_source TEXT DEFAULT 'SYSTEM',
    FOREIGN KEY (student_hash_key) REFERENCES Hub_Student(student_hash_key),
    FOREIGN KEY (subject_hash_key) REFERENCES Hub_Subject(subject_hash_key),
    UNIQUE(student_hash_key, subject_hash_key, effective_date)
);

-- Связь: Студент - Экзамен (сдача)
CREATE TABLE Link_Student_Exam (
    link_student_exam_hash_key TEXT PRIMARY KEY,
    student_hash_key TEXT NOT NULL,
    exam_hash_key TEXT NOT NULL,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM',
    FOREIGN KEY (student_hash_key) REFERENCES Hub_Student(student_hash_key),
    FOREIGN KEY (exam_hash_key) REFERENCES Hub_Exam(exam_hash_key),
    UNIQUE(student_hash_key, exam_hash_key, effective_date)
);

-- Связь: Предмет - Тема (включение)
CREATE TABLE Link_Subject_Topic (
    link_subject_topic_hash_key TEXT PRIMARY KEY,
    subject_hash_key TEXT NOT NULL,
    topic_hash_key TEXT NOT NULL,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM',
    FOREIGN KEY (subject_hash_key) REFERENCES Hub_Subject(subject_hash_key),
    FOREIGN KEY (topic_hash_key) REFERENCES Hub_Topic(topic_hash_key),
    UNIQUE(subject_hash_key, topic_hash_key, effective_date)
);

-- Связь: Тема - Ресурс (обеспечение)
CREATE TABLE Link_Topic_Resource (
    link_topic_resource_hash_key TEXT PRIMARY KEY,
    topic_hash_key TEXT NOT NULL,
    resource_hash_key TEXT NOT NULL,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM',
    FOREIGN KEY (topic_hash_key) REFERENCES Hub_Topic(topic_hash_key),
    FOREIGN KEY (resource_hash_key) REFERENCES Sat_Resource_Details(resource_hash_key),
    UNIQUE(topic_hash_key, resource_hash_key, effective_date)
);

-- Связь: Студент - Тема - Прогресс (изучение)
CREATE TABLE Link_Student_Topic_Progress (
    link_student_topic_progress_hash_key TEXT PRIMARY KEY,
    student_hash_key TEXT NOT NULL,
    topic_hash_key TEXT NOT NULL,
    progress_hash_key TEXT NOT NULL,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM',
    FOREIGN KEY (student_hash_key) REFERENCES Hub_Student(student_hash_key),
    FOREIGN KEY (topic_hash_key) REFERENCES Hub_Topic(topic_hash_key),
    FOREIGN KEY (progress_hash_key) REFERENCES Sat_StudyProgress_Details(progress_hash_key),
    UNIQUE(student_hash_key, topic_hash_key, progress_hash_key, effective_date)
);

-- Связь: Студент - Экзамен - Результат (оценка)
CREATE TABLE Link_Student_Exam_Result (
    link_student_exam_result_hash_key TEXT PRIMARY KEY,
    student_hash_key TEXT NOT NULL,
    exam_hash_key TEXT NOT NULL,
    result_hash_key TEXT NOT NULL,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM',
    FOREIGN KEY (student_hash_key) REFERENCES Hub_Student(student_hash_key),
    FOREIGN KEY (exam_hash_key) REFERENCES Hub_Exam(exam_hash_key),
    FOREIGN KEY (result_hash_key) REFERENCES Sat_ExamResult_Details(result_hash_key),
    UNIQUE(student_hash_key, exam_hash_key, result_hash_key, effective_date)
);

-- Связь: Расписание занятий
CREATE TABLE Link_Study_Schedule (
    link_study_schedule_hash_key TEXT PRIMARY KEY,
    student_hash_key TEXT NOT NULL,
    topic_hash_key TEXT NOT NULL,
    schedule_date DATE NOT NULL,                  -- Дата занятия
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    record_source TEXT DEFAULT 'SYSTEM',
    FOREIGN KEY (student_hash_key) REFERENCES Hub_Student(student_hash_key),
    FOREIGN KEY (topic_hash_key) REFERENCES Hub_Topic(topic_hash_key),
    UNIQUE(student_hash_key, topic_hash_key, schedule_date, effective_date)
);

-- =============================================================================
-- ИНДЕКСЫ для оптимизации запросов
-- =============================================================================

-- Индексы для хабов
CREATE INDEX idx_hub_student_id ON Hub_Student(student_id);
CREATE INDEX idx_hub_subject_id ON Hub_Subject(subject_id);
CREATE INDEX idx_hub_exam_id ON Hub_Exam(exam_id);
CREATE INDEX idx_hub_topic_id ON Hub_Topic(topic_id);

-- Индексы для спутников (для поиска по текущим версиям)
CREATE INDEX idx_sat_student_current ON Sat_Student_Details(is_current, student_hash_key);
CREATE INDEX idx_sat_subject_current ON Sat_Subject_Details(is_current, subject_hash_key);
CREATE INDEX idx_sat_exam_current ON Sat_Exam_Details(is_current, exam_hash_key);
CREATE INDEX idx_sat_topic_current ON Sat_Topic_Details(is_current, topic_hash_key);
CREATE INDEX idx_sat_resource_current ON Sat_Resource_Details(is_current);
CREATE INDEX idx_sat_progress_current ON Sat_StudyProgress_Details(is_current);
CREATE INDEX idx_sat_result_current ON Sat_ExamResult_Details(is_current);

-- Индексы для спутников (для поиска по датам)
CREATE INDEX idx_sat_student_dates ON Sat_Student_Details(effective_date, end_date);
CREATE INDEX idx_sat_subject_dates ON Sat_Subject_Details(effective_date, end_date);
CREATE INDEX idx_sat_exam_dates ON Sat_Exam_Details(effective_date, end_date);
CREATE INDEX idx_sat_topic_dates ON Sat_Topic_Details(effective_date, end_date);

-- Индексы для связей
CREATE INDEX idx_link_student_subject ON Link_Student_Subject(student_hash_key, subject_hash_key);
CREATE INDEX idx_link_student_exam ON Link_Student_Exam(student_hash_key, exam_hash_key);
CREATE INDEX idx_link_subject_topic ON Link_Subject_Topic(subject_hash_key, topic_hash_key);
CREATE INDEX idx_link_topic_resource ON Link_Topic_Resource(topic_hash_key, resource_hash_key);
CREATE INDEX idx_link_student_topic_progress ON Link_Student_Topic_Progress(student_hash_key, topic_hash_key);
CREATE INDEX idx_link_student_exam_result ON Link_Student_Exam_Result(student_hash_key, exam_hash_key);
CREATE INDEX idx_link_study_schedule ON Link_Study_Schedule(student_hash_key, topic_hash_key);

-- Индексы для временных диапазонов
CREATE INDEX idx_link_student_subject_dates ON Link_Student_Subject(effective_date, end_date);
CREATE INDEX idx_link_student_exam_dates ON Link_Student_Exam(effective_date, end_date);

-- =============================================================================
-- ТРИГГЕРЫ для автоматизации процессов Data Vault
-- =============================================================================

-- Триггер для автоматического закрытия предыдущих версий в спутниках
CREATE TRIGGER close_previous_student_version 
BEFORE INSERT ON Sat_Student_Details
FOR EACH ROW
WHEN NEW.is_current = 1
BEGIN
    UPDATE Sat_Student_Details 
    SET is_current = 0, end_date = DATE(NEW.effective_date, '-1 day')
    WHERE student_hash_key = NEW.student_hash_key AND is_current = 1;
END;

-- Триггер для автоматического закрытия предыдущих версий в связях
CREATE TRIGGER close_previous_link_student_subject
BEFORE INSERT ON Link_Student_Subject
FOR EACH ROW
WHEN NEW.is_current = 1
BEGIN
    UPDATE Link_Student_Subject 
    SET is_current = 0, end_date = DATE(NEW.effective_date, '-1 day')
    WHERE student_hash_key = NEW.student_hash_key 
    AND subject_hash_key = NEW.subject_hash_key 
    AND is_current = 1;
END;

-- =============================================================================
-- ПРЕДСТАВЛЕНИЯ (VIEWS) для удобства работы с текущими данными
-- =============================================================================

-- Представление: Текущие данные студентов
CREATE VIEW Current_Students AS
SELECT 
    h.student_id,
    s.name,
    s.email,
    s.level,
    s.effective_date,
    s.load_date
FROM Hub_Student h
JOIN Sat_Student_Details s ON h.student_hash_key = s.student_hash_key
WHERE s.is_current = 1;

-- Представление: Текущие данные предметов
CREATE VIEW Current_Subjects AS
SELECT 
    h.subject_id,
    s.title,
    s.credits,
    s.difficulty,
    s.description,
    s.effective_date
FROM Hub_Subject h
JOIN Sat_Subject_Details s ON h.subject_hash_key = s.subject_hash_key
WHERE s.is_current = 1;

-- Представление: Активные связи студенты-предметы
CREATE VIEW Current_Student_Subjects AS
SELECT 
    hs.student_id,
    hsub.subject_id,
    ss.name AS student_name,
    ssub.title AS subject_title,
    l.effective_date,
    l.load_date
FROM Link_Student_Subject l
JOIN Hub_Student hs ON l.student_hash_key = hs.student_hash_key
JOIN Hub_Subject hsub ON l.subject_hash_key = hsub.subject_hash_key
JOIN Sat_Student_Details ss ON hs.student_hash_key = ss.student_hash_key AND ss.is_current = 1
JOIN Sat_Subject_Details ssub ON hsub.subject_hash_key = ssub.subject_hash_key AND ssub.is_current = 1
WHERE l.is_current = 1;

-- =============================================================================
-- ФУНКЦИИ для работы с хэшами (упрощенная реализация для SQLite)
