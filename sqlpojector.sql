-- 1. For each class, find the student(s) who scored the highest in Science.
SELECT c.class_name, s.student_name
FROM Classes c
JOIN Students st ON c.class_id = st.class_id
JOIN Scores sc ON st.student_id = sc.student_id
WHERE sc.subject = 'Science'
      AND sc.score = (
        SELECT MAX(score)
        FROM Scores
        WHERE subject = 'Science'
      );


-- 2. List the names of students who scored lower in Math than their average Science score
SELECT st.student_name
FROM Students st
JOIN Scores sc_math ON st.student_id = sc_math.student_id AND sc_math.subject = 'Math'
JOIN Scores sc_science ON st.student_id = sc_science.student_id AND sc_science.subject = 'Science'
GROUP BY st.student_id, st.student_name
HAVING AVG(sc_math.score) < AVG(sc_science.score);


-- 3. Display the class names with the highest number of students who scored above 80 in any subject.
WITH StudentSubjectScores AS (
  SELECT st.class_id, st.student_id, sc.subject, sc.score
  FROM Students st
  JOIN Scores sc ON st.student_id = sc.student_id
  WHERE sc.score > 80
)

SELECT c.class_name, COUNT(DISTINCT sss.student_id) AS num_students_above_80
FROM Classes c
JOIN StudentSubjectScores sss ON c.class_id = sss.class_id
GROUP BY c.class_name
HAVING COUNT(DISTINCT sss.student_id) = (
  SELECT MAX(num_students_above_80)
  FROM (
    SELECT c.class_id, COUNT(DISTINCT sss.student_id) AS num_students_above_80
    FROM Classes c
    JOIN StudentSubjectScores sss ON c.class_id = sss.class_id
    GROUP BY c.class_id
  ) AS temp
);


-- 4. Find the students who scored the highest in each subject.
WITH MaxScores AS (
  SELECT subject, MAX(score) AS max_score
  FROM Scores
  GROUP BY subject
)

SELECT s.student_name, sc.subject, sc.score
FROM Students s
JOIN Scores sc ON s.student_id = sc.student_id
JOIN MaxScores ms ON sc.subject = ms.subject
WHERE sc.score = ms.max_score;


-- 5. List the names of students who scored higher than the average of any students score in their own class.
WITH ClassAvgScores AS (
  SELECT st.class_id, AVG(sc.score) AS class_avg_score
  FROM Students st
  JOIN Scores sc ON st.student_id = sc.student_id
  GROUP BY st.class_id
)

SELECT s.student_name, sc.score, cas.class_avg_score
FROM Students s
JOIN Scores sc ON s.student_id = sc.student_id
JOIN ClassAvgScores cas ON s.class_id = cas.class_id
WHERE sc.score > cas.class_avg_score;


-- 6. Find the class(es) where the students average age is above the average age of all students.
WITH AvgAge AS (
  SELECT AVG(age) AS overall_avg_age
  FROM Students
),
ClassAvgAge AS (
  SELECT class_id, AVG(age) AS class_avg_age
  FROM Students
  GROUP BY class_id
)

SELECT c.class_name
FROM Classes c
JOIN ClassAvgAge caa ON c.class_id = caa.class_id
CROSS JOIN AvgAge aa
WHERE caa.class_avg_age > aa.overall_avg_age;


-- 7. Display the student names and their total scores, ordered by the total score in descending order.
SELECT s.student_name, SUM(sc.score) AS total_score
FROM Students s
JOIN Scores sc ON s.student_id = sc.student_id
GROUP BY s.student_name
ORDER BY total_score DESC;


-- 8. Find the student(s) who scored the highest in the class with the lowest average score.
WITH ClassAvgScores AS (
  SELECT st.class_id, AVG(sc.score) AS class_avg_score
  FROM Students st
  JOIN Scores sc ON st.student_id = sc.student_id
  GROUP BY st.class_id
),
MinClassAvg AS (
  SELECT MIN(class_avg_score) AS min_avg_score
  FROM ClassAvgScores
)

SELECT s.student_name, sc.score
FROM Students s
JOIN Scores sc ON s.student_id = sc.student_id
JOIN ClassAvgScores cas ON s.class_id = cas.class_id
JOIN MinClassAvg mca ON cas.class_avg_score = mca.min_avg_score
WHERE sc.score = (
  SELECT MAX(score)
  FROM Scores
  WHERE student_id = s.student_id
);


-- 9. List the names of students who scored the same as Alice in at least one subject.
SELECT DISTINCT st.student_name
FROM Students st
JOIN Scores sa ON st.student_id = sa.student_id
JOIN Scores alice ON alice.subject = sa.subject AND alice.student_id = 1  -- Assuming Alice's student_id is 1
WHERE st.student_id <> 1 AND sa.score = alice.score;


-- 10. Display the class names along with the number of students who scored below the average score in their class.
WITH ClassAvgScores AS (
  SELECT st.class_id, AVG(sc.score) AS class_avg_score
  FROM Students st
  JOIN Scores sc ON st.student_id = sc.student_id
  GROUP BY st.class_id
)

SELECT c.class_name, COUNT(*) AS num_students_below_avg
FROM Classes c
JOIN Students s ON c.class_id = s.class_id
JOIN Scores sc ON s.student_id = sc.student_id
JOIN ClassAvgScores cas ON c.class_id = cas.class_id
WHERE sc.score < cas.class_avg_score
GROUP BY c.class_name;
