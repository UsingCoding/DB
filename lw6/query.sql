# 1. Добавить внешние ключи
ALTER TABLE student
	ADD CONSTRAINT student_group_id_group_fk
		FOREIGN KEY (id_group) REFERENCES group;

ALTER TABLE lesson
	ADD CONSTRAINT lesson_group_id_group_fk
		FOREIGN key (id_group) REFERENCES group;

ALTER TABLE lesson
	ADD CONSTRAINT LESSON_SUBJECT_ID_SUBJECT_FK
		foreign KEY (id_subject) REFERENCES subject;

ALTER TABLE lesson
	ADD CONSTRAINT lesson_teacher_id_teacher_fk
		FOREIGN KEY (id_teacher) REFERENCES teacher;

ALTER TABLE mark
	ADD CONSTRAINT mark_lesson_id_lesson_fk
		FOREIGN KEY (id_lesson) REFERENCES lesson;

ALTER TABLE mark
	ADD CONSTRAINT mark_student_id_student_fk
		FOREIGN KEY (id_student) REFERENCES student;

# 2. Выдать оценки студентов по информатике если они обучаются данному предмету. Оформить выдачу данных с использованием view.
CREATE OR REPLACE VIEW students_mark AS
SELECT student.name,
       mark.mark
FROM mark
         LEFT JOIN lesson on mark.id_lesson = lesson.id_lesson
         LEFT JOIN student on mark.id_student = student.id_student
         LEFT JOIN subject on lesson.id_subject = subject.id_subject;

# 3. Дать информацию о должниках с указанием фамилии студента и названия предмета. Должниками считаются студенты, не имеющие оценки по предмету, который ведется в группе. Оформить в виде процедуры, на входе идентификатор группы.
CREATE OR REPLACE FUNCTION debtor_info(identifier varchar)
    RETURNS TABLE
            (
                name    varchar,
                subject varchar
            )
    LANGUAGE SQL
AS
$$
SELECT student.name,
       subject.name
FROM student
         INNER JOIN group ON group.id_group = student.id_group
         INNER JOIN lesson ON lesson.id_group = group.id_group
         LEFT JOIN mark ON mark.id_student = student.id_student AND mark.id_lesson = lesson.id_lesson
         INNER JOIN subject ON subject.id_subject = lesson.ID_SUBJECT
WHERE group.name = identifier
GROUP BY student.name, subject.name
HAVING COUNT(mark.mark) = 0
ORDER BY student.name
$$;


SELECT *
FROM debtor_info('ПС');
SELECT *
FROM debtor_info('ИВТ');
SELECT *
FROM debtor_info('БИ');
SELECT *
FROM debtor_info('ВМ');

# 4. Дать среднюю оценку студентов по каждому предмету для тех предметов, по которым занимается не менее 35 студентов.
SELECT subject.name,
       AVG(mark.mark)
FROM mark
         LEFT JOIN lesson ON mark.id_lesson = lesson.id_lesson
         LEFT JOIN subject ON lesson.id_subject = subject.id_subject
         LEFT JOIN student ON mark.id_student = student.id_student
GROUP BY subject.name
HAVING (COUNT(DISTINCT student.id_student) >= 35)

# 5. Дать оценки студентов специальности ВМ по всем проводимым предметам с указанием группы, фамилии, предмета, даты. При отсутствии оценки заполнить значениями NULL поля оценки.
SELECT subject.name AS subject_name,
       group.name AS group_name,
       student.name AS student_name,
       mark.mark,
       lesson.date
FROM student
         LEFT JOIN group ON student.id_group = group.id_group
         LEFT JOIN lesson ON lesson.id_group = group.id_group
         LEFT JOIN subject ON lesson.id_subject = subject.id_subject
         LEFT JOIN mark ON (lesson.id_lesson = mark.id_lesson AND student.id_student = mark.id_student)
WHERE group.name = 'ВМ'
ORDER BY subject.name;

# 6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету
#    БД до 12.05, повысить эти оценки на 1 балл.
UPDATE mark
SET mark = (mark + 1)
WHERE mark.id_student IN (
    SELECT student.id_student
    FROM student
             LEFT JOIN group ON student.id_group = group.id_group
    WHERE group.name = 'ПС')
  AND mark.id_lesson IN (
    SELECT lesson.id_lesson
    FROM lesson
             LEFT JOIN group ON group.id_group = lesson.id_group
             LEFT JOIN student ON group.id_group = student.id_group
             LEFT JOIN subject ON lesson.id_subject = subject.id_subject
             LEFT JOIN mark ON (mark.id_student = student.id_student AND mark.id_lesson = lesson.id_lesson)
    WHERE lesson.date < CAST('2019-05-12' AS date)
      AND subject.name = 'БД'
)
  AND mark.mark < 5;

# 7. Добавить необходимые индексы.
CREATE INDEX group_name_index
	ON group (name);

CREATE INDEX lesson_id_group_index
	ON lesson (id_group);

CREATE INDEX lesson_id_subject_index
	ON lesson (id_subject);

CREATE INDEX lesson_id_teacher_index
	ON lesson (id_teacher);

CREATE INDEX mark_id_lesson_index
	ON mark (id_lesson);

CREATE INDEX mark_id_student_index
	ON mark (id_student);

CREATE INDEX mark_mark_index
	ON mark (mark);

CREATE INDEX student_id_group_index
	ON student (id_group);

CREATE INDEX student_name_index
	ON student (name);

CREATE INDEX subject_name_index
	ON subject (name);

CREATE INDEX teacher_name_index
	ON teacher (name);