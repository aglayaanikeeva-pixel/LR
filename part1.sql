-- Таблица: Студенты
-- Назначение: Хранение информации о студентах
-- =============================================================================
CREATE TABLE Students (
    student_id INTEGER PRIMARY KEY AUTOINCREMENT,      -- Уникальный идентификатор студента
    name TEXT NOT NULL,                                -- Полное имя студента
    email TEXT UNIQUE NOT NULL,                        -- Электронная почта (уникальная)
    level TEXT CHECK(level IN ('бакалавр', 'магистр', 'аспирант')) DEFAULT 'бакалавр',
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP    -- Дата регистрации в системе
);

-- =============================================================================
-- Таблица: Предметы
-- Назначение: Каталог учебных дисциплин
-- =============================================================================
CREATE TABLE Subjects (
    subject_id INTEGER PRIMARY KEY AUTOINCREMENT,      -- Уникальный идентификатор предмета
    title TEXT NOT NULL UNIQUE,                        -- Название дисциплины
    credits INTEGER NOT NULL CHECK(credits > 0),       -- Количество кредитов
    difficulty INTEGER CHECK(difficulty BETWEEN 1 AND 5) DEFAULT 3, -- Сложность (1-5)
    description TEXT,                                  -- Описание предмета
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- Таблица: Темы
-- Назначение: Разделы и темы within каждого предмета
-- =============================================================================
CREATE TABLE Topics (
    topic_id INTEGER PRIMARY KEY AUTOINCREMENT,        -- Уникальный идентификатор темы
    subject_id INTEGER NOT NULL,                       -- Ссылка на предмет
    title TEXT NOT NULL,                               -- Название темы
    hours_required REAL NOT NULL CHECK(hours_required > 0), -- Часов для изучения
    priority INTEGER CHECK(priority BETWEEN 1 AND 3) DEFAULT 2, -- Приоритет (1-высокий, 2-средний, 3-низкий)
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id) ON DELETE CASCADE
);

-- =============================================================================
-- Таблица: Экзамены
-- Назначение: Информация о предстоящих экзаменах
-- =============================================================================
CREATE TABLE Exams (
    exam_id INTEGER PRIMARY KEY AUTOINCREMENT,         -- Уникальный идентификатор экзамена
    subject_id INTEGER NOT NULL,                       -- Ссылка на предмет
    exam_date DATE NOT NULL,                           -- Дата проведения экзамена
    max_score INTEGER NOT NULL CHECK(max_score > 0),   -- Максимальный балл
    min_excellent_score INTEGER NOT NULL,              -- Минимальный балл для "отлично"
    description TEXT,                                  -- Дополнительная информация
    FOREIGN KEY (subject_id) REFERENCES Subjects(subject_id) ON DELETE CASCADE
);

-- =============================================================================
-- Таблица: Учебные ресурсы
-- Назначение: Материалы для подготовки по каждой теме
-- =============================================================================
CREATE TABLE Resources (
    resource_id INTEGER PRIMARY KEY AUTOINCREMENT,     -- Уникальный идентификатор ресурса
    topic_id INTEGER NOT NULL,                         -- Ссылка на тему
    type TEXT CHECK(type IN ('книга', 'статья', 'видео', 'задачи', 'лекции')),
    title TEXT NOT NULL,                               -- Название ресурса
    url TEXT,                                          -- Ссылка на ресурс (если есть)
    description TEXT,                                  -- Описание ресурса
    quality_rating INTEGER CHECK(quality_rating BETWEEN 1 AND 5), -- Качество ресурса (1-5)
    FOREIGN KEY (topic_id) REFERENCES Topics(topic_id) ON DELETE CASCADE
);

-- =============================================================================
-- Таблица: Расписание занятий
-- Назначение: Планирование подготовки студента
-- =============================================================================
CREATE TABLE StudySchedule (
    schedule_id INTEGER PRIMARY KEY AUTOINCREMENT,     -- Уникальный идентификатор записи
    student_id INTEGER NOT NULL,                       -- Ссылка на студента
    topic_id INTEGER NOT NULL,                         -- Ссылка на тему
    study_date DATE NOT NULL,                          -- Запланированная дата занятия
    hours_planned REAL NOT NULL CHECK(hours_planned > 0), -- Планируемое время
    completed BOOLEAN DEFAULT FALSE,                   -- Статус выполнения
    actual_hours REAL,                                 -- Фактически затраченное время
    notes TEXT,                                        -- Заметки о занятии
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES Topics(topic_id) ON DELETE CASCADE
);

-- =============================================================================
-- Таблица: Прогресс изучения
-- Назначение: Отслеживание прогресса по темам
-- =============================================================================
CREATE TABLE StudyProgress (
    progress_id INTEGER PRIMARY KEY AUTOINCREMENT,     -- Уникальный идентификатор прогресса
    student_id INTEGER NOT NULL,                       -- Ссылка на студента
    topic_id INTEGER NOT NULL,                         -- Ссылка на тему
    understanding_level INTEGER CHECK(understanding_level BETWEEN 1 AND 5) DEFAULT 1, -- Уровень понимания (1-5)
    hours_studied REAL DEFAULT 0,                      -- Всего часов изучено
    last_studied DATE,                                 -- Дата последнего занятия
    confidence_level INTEGER CHECK(confidence_level BETWEEN 1 AND 5), -- Уверенность в теме (1-5)
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES Topics(topic_id) ON DELETE CASCADE,
    UNIQUE(student_id, topic_id)                       -- Один прогресс на студента и тему
);

-- =============================================================================
-- Таблица: Результаты экзаменов
-- Назначение: Хранение итоговых оценок
-- =============================================================================
CREATE TABLE ExamResults (
    result_id INTEGER PRIMARY KEY AUTOINCREMENT,       -- Уникальный идентификатор результата
    student_id INTEGER NOT NULL,                       -- Ссылка на студента
    exam_id INTEGER NOT NULL,                          -- Ссылка на экзамен
    score INTEGER NOT NULL CHECK(score >= 0),          -- Полученный балл
    grade TEXT CHECK(grade IN ('неуд', 'удовл', 'хорошо', 'отлично')), -- Оценка
    preparation_time INTEGER,                          -- Всего часов подготовки
    achieved_excellent BOOLEAN,                        -- Достигнута ли цель "отлично"
    feedback TEXT,                                     -- Самоанализ подготовки
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (exam_id) REFERENCES Exams(exam_id) ON DELETE CASCADE,
    UNIQUE(student_id, exam_id)                        -- Один результат на студента и экзамен
);

-- =============================================================================
-- ИНДЕКСЫ для оптимизации запросов
-- =============================================================================

-- Индексы для таблицы Students
CREATE INDEX idx_students_email ON Students(email);
CREATE INDEX idx_students_name ON Students(name);

-- Индексы для таблицы Topics
CREATE INDEX idx_topics_subject ON Topics(subject_id);
CREATE INDEX idx_topics_priority ON Topics(priority);

-- Индексы для таблицы Exams
CREATE INDEX idx_exams_date ON Exams(exam_date);
CREATE INDEX idx_exams_subject ON Exams(subject_id);

-- Индексы для таблицы Resources
CREATE INDEX idx_resources_topic ON Resources(topic_id);
CREATE INDEX idx_resources_type ON Resources(type);
CREATE INDEX idx_resources_quality ON Resources(quality_rating);

-- Индексы для таблицы StudySchedule
CREATE INDEX idx_schedule_student ON StudySchedule(student_id);
CREATE INDEX idx_schedule_date ON StudySchedule(study_date);
CREATE INDEX idx_schedule_completed ON StudySchedule(completed);

-- Индексы для таблицы StudyProgress
CREATE INDEX idx_progress_student ON StudyProgress(student_id);
CREATE INDEX idx_progress_topic ON StudyProgress(topic_id);
CREATE INDEX idx_progress_understanding ON StudyProgress(understanding_level);

-- Индексы для таблицы ExamResults
CREATE INDEX idx_results_student ON ExamResults(student_id);
CREATE INDEX idx_results_exam ON ExamResults(exam_id);
CREATE INDEX idx_results_grade ON ExamResults(grade);

-- =============================================================================
-- ТРИГГЕРЫ для автоматизации процессов
-- =============================================================================

-- Триггер для автоматического расчета оценки по баллам
CREATE TRIGGER calculate_grade_trigger 
BEFORE INSERT ON ExamResults
FOR EACH ROW
BEGIN
    -- Определяем оценку на основе баллов и минимального порога для "отлично"
    SELECT 
        CASE 
            WHEN NEW.score >= (SELECT min_excellent_score FROM Exams WHERE exam_id = NEW.exam_id) THEN 'отлично'
            WHEN NEW.score >= (SELECT min_excellent_score FROM Exams WHERE exam_id = NEW.exam_id) * 0.8 THEN 'хорошо'
            WHEN NEW.score >= (SELECT min_excellent_score FROM Exams WHERE exam_id = NEW.exam_id) * 0.6 THEN 'удовл'
            ELSE 'неуд'
        END
    INTO NEW.grade;
    
    -- Устанавливаем флаг достижения цели
    SET NEW.achieved_excellent = (NEW.grade = 'отлично');
END;

-- Триггер для обновления даты последнего изучения в прогрессе
CREATE TRIGGER update_progress_date_trigger 
AFTER UPDATE ON StudyProgress
FOR EACH ROW
WHEN NEW.hours_studied > OLD.hours_studied
BEGIN
    UPDATE StudyProgress 
    SET last_studied = DATE('now') 
    WHERE progress_id = NEW.progress_id;
END;

-- =============================================================================
-- ПРЕДСТАВЛЕНИЯ (VIEWS) для удобства работы
-- =============================================================================

-- Представление: Общий прогресс подготовки к экзамену
CREATE VIEW ExamPreparationProgress AS
SELECT 
    s.name AS student_name,
    sub.title AS subject_title,
    e.exam_date,
    COUNT(DISTINCT t.topic_id) AS total_topics,
    COUNT(DISTINCT sp.topic_id) AS studied_topics,
    ROUND(COUNT(DISTINCT sp.topic_id) * 100.0 / COUNT(DISTINCT t.topic_id), 1) AS progress_percent,
    SUM(sp.hours_studied) AS total_hours_studied
FROM Students s
CROSS JOIN Subjects sub
JOIN Exams e ON e.subject_id = sub.subject_id
JOIN Topics t ON t.subject_id = sub.subject_id
LEFT JOIN StudyProgress sp ON sp.topic_id = t.topic_id AND sp.student_id = s.student_id
GROUP BY s.student_id, sub.subject_id, e.exam_id;

-- Представление: Темы для срочного изучения (высокий приоритет)
CREATE VIEW HighPriorityTopics AS
SELECT 
    s.name AS student_name,
    sub.title AS subject_title,
    t.title AS topic_title,
    t.priority,
    sp.understanding_level,
    t.hours_required - COALESCE(sp.hours_studied, 0) AS hours_remaining
FROM Students s
JOIN StudyProgress sp ON sp.student_id = s.student_id
JOIN Topics t ON t.topic_id = sp.topic_id
JOIN Subjects sub ON sub.subject_id = t.subject_id
WHERE t.priority = 1 AND sp.understanding_level < 4
ORDER BY hours_remaining DESC;
