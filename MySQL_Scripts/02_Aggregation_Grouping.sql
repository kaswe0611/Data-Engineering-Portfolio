-- ===================================================
-- 作業 3: 聚合函數 (SUM, AVG, MIN, MAX, COUNT)
-- ===================================================

-- #01.計算所有員工的年薪總和
SELECT SUM(SAL * 12) AS 薪資總和
FROM EMP;

-- #02.計算所有員工的平均月薪
SELECT AVG(SAL) AS 平均月薪
FROM EMP;

-- #03.依部門編號 (DEPTNO) 分組，計算各部門的薪資總和
SELECT DEPTNO, SUM(SAL)
FROM EMP
GROUP BY DEPTNO
ORDER BY DEPTNO;

-- #04.依職稱 (JOB) 分組，計算各職稱的平均薪資與人數
SELECT JOB, AVG(SAL) AS AverageSalary, COUNT(*) AS EmployeeCount
FROM EMP
GROUP BY JOB;

-- #05.依部門編號 (DEPTNO) 分組，計算各部門的最低與最高薪資
SELECT DEPTNO, MIN(SAL), MAX(SAL)
FROM EMP
GROUP BY DEPTNO;

-- #06.依到職年 (HIREDATE) 分組，計算各年到職的人數
SELECT YEAR(HIREDATE) AS HireYear, COUNT(*) AS EmployeeCount
FROM EMP
GROUP BY YEAR(HIREDATE);


-- ===================================================
-- 作業 4: 分組過濾 (HAVING)
-- ===================================================

-- #01.列出平均薪資超過2500的部門編號與平均薪資
SELECT DEPTNO, AVG(SAL)
FROM EMP
GROUP BY DEPTNO
HAVING AVG(SAL) > 2500;

-- #02.列出到職人數剛好為1人的到職年
SELECT YEAR(HIREDATE) AS HireYear, COUNT(*) AS EmployeeCount
FROM EMP
GROUP BY YEAR(HIREDATE)
HAVING COUNT(*) = 1;

-- #03.列出薪資總和低於10000的部門編號與薪資總和，並依部門編號遞減排序
SELECT DEPTNO, SUM(SAL)
FROM EMP
GROUP BY DEPTNO
HAVING SUM(SAL) < 10000
ORDER BY DEPTNO DESC;

-- #04.列出平均薪資大於2000且人數少於2人的職稱
SELECT JOB, AVG(SAL) AS AverageSalary, COUNT(*) AS EmployeeCount
FROM EMP
GROUP BY JOB
HAVING AVG(SAL) > 2000
    AND COUNT(*) < 2;
    
-- #05.列出最低薪資低於或等於1200的部門編號、最低與最高薪資
SELECT DEPTNO, MIN(SAL), MAX(SAL)
FROM EMP
GROUP BY DEPTNO
HAVING MIN(SAL) <= 1200;
