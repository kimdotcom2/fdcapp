/* ============================================================================
   TrainingDB - DDL 스크립트
   ----------------------------------------------------------------------------
   서버         : localhost
   데이터베이스 : TrainingDB
   계정         : test / 1234 (SQL 인증)
   ----------------------------------------------------------------------------
   생성 테이블
     1) dbo.TB_EQUIPMENT  : 설비 마스터
     2) dbo.TB_EQUIP_LOG  : 설비 로그
   ============================================================================ */

USE [TrainingDB];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


/* ----------------------------------------------------------------------------
   (선택) 기존 테이블을 삭제하고 새로 만들려면 아래 주석을 해제하세요.
   ※ 실행하면 기존 데이터가 모두 삭제됩니다.
   ---------------------------------------------------------------------------- */
-- IF OBJECT_ID(N'dbo.TB_EQUIP_LOG', N'U') IS NOT NULL DROP TABLE dbo.TB_EQUIP_LOG;
-- GO
-- IF OBJECT_ID(N'dbo.TB_EQUIPMENT', N'U') IS NOT NULL DROP TABLE dbo.TB_EQUIPMENT;
-- GO


/* ============================================================================
   1. TB_EQUIPMENT : 설비 마스터
   ============================================================================ */
IF OBJECT_ID(N'dbo.TB_EQUIPMENT', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TB_EQUIPMENT
    (
        EQUIP_ID    NVARCHAR(200) NOT NULL,     -- 설비 고유 코드
        EQUIP_NAME  NVARCHAR(200) NOT NULL,     -- 설비명
        LINE_NAME   NVARCHAR(200) NOT NULL,     -- 배치 라인명
        STATUS      NVARCHAR(200) NULL          -- 설비 상태 (IDLE, RUN 등)
        CONSTRAINT DF_TB_EQUIPMENT_STATUS DEFAULT (N'IDLE'),
        CREATE_DT   DATETIME      NULL,         -- 생성 일시

        CONSTRAINT PK_TB_EQUIPMENT PRIMARY KEY CLUSTERED (EQUIP_ID)
    );
END
GO

/* ----------------------------------------------------------------------------
   (기존 테이블이 이미 있는 경우) CREATE_DT 컬럼 추가
   ---------------------------------------------------------------------------- */
IF OBJECT_ID(N'dbo.TB_EQUIPMENT', N'U') IS NOT NULL
   AND COL_LENGTH(N'dbo.TB_EQUIPMENT', N'CREATE_DT') IS NULL
BEGIN
    ALTER TABLE dbo.TB_EQUIPMENT ADD CREATE_DT DATETIME NULL;
END
GO


/* ============================================================================
   2. TB_EQUIP_LOG : 설비 로그
   ============================================================================ */
IF OBJECT_ID(N'dbo.TB_EQUIP_LOG', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TB_EQUIP_LOG
    (
        LOG_ID     BIGINT        IDENTITY(1,1) NOT NULL,    -- 로그 ID (자동 증가)
        EQUIP_ID   NVARCHAR(200) NULL,                      -- 설비 고유 코드
        LOG_TYPE   NVARCHAR(50)  NULL,                      -- 로그 유형
        LOG_MSG    NVARCHAR(200) NULL,                      -- 로그 메시지
        OCCUR_DT   DATETIME      NULL,                      -- 발생 일시

        CONSTRAINT PK_TB_EQUIP_LOG PRIMARY KEY CLUSTERED (LOG_ID)
    );
END
GO


/* ============================================================================
   3. TB_EQUIP_LIMIT : 설비 임계치 규칙
   ----------------------------------------------------------------------------
   ※ EQUIP_ID는 설비 식별 코드지만 외래키(FK)는 걸지 않습니다.
   ============================================================================ */
IF OBJECT_ID(N'dbo.TB_EQUIP_LIMIT', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TB_EQUIP_LIMIT
    (
        LIMIT_ID     BIGINT         IDENTITY(1,1) NOT NULL,   -- 임계치 규칙 번호
        EQUIP_ID     NVARCHAR(200)  NOT NULL,                 -- 설비 식별 코드 (FK 없음)
        PARAM_NAME   NVARCHAR(200)  NOT NULL,                 -- 측정 파라미터 (TEMP, PRESSURE)
        LOWER_LIMIT  FLOAT          NOT NULL,                 -- 정상 하한값 (예: 20.0)
        UPPER_LIMIT  FLOAT          NOT NULL,                 -- 정상 상한값 (예: 80.0)
        CREATE_DT    DATETIME       NULL                      -- 룰 등록 일시
            CONSTRAINT DF_TB_EQUIP_LIMIT_CREATE_DT DEFAULT (GETDATE()),

        CONSTRAINT PK_TB_EQUIP_LIMIT PRIMARY KEY CLUSTERED (LIMIT_ID)
    );
END
GO


/* ============================================================================
   4. TB_EQUIP_DATA : 설비 센서 수집 데이터
   ----------------------------------------------------------------------------
   ※ EQUIP_ID는 설비 식별 코드지만 외래키(FK)는 걸지 않습니다.
   ============================================================================ */
IF OBJECT_ID(N'dbo.TB_EQUIP_DATA', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TB_EQUIP_DATA
    (
        DATA_ID      BIGINT         IDENTITY(1,1) NOT NULL,   -- 수집 데이터 일련번호
        EQUIP_ID     NVARCHAR(200)  NOT NULL,                 -- 설비 식별 코드 (FK 없음)
        TEMP_VAL     FLOAT          NOT NULL,                 -- 온도 측정 센서값 (℃)
        PRESS_VAL    FLOAT          NOT NULL,                 -- 압력 측정 센서값 (bar)
        IS_FAULT     NVARCHAR(200)  NULL                      -- 판정 결과 (NORMAL / ALARM)
            CONSTRAINT DF_TB_EQUIP_DATA_IS_FAULT DEFAULT (N'NORMAL'),
        COLLECT_DT   DATETIME       NULL                      -- 데이터 수집 일시
            CONSTRAINT DF_TB_EQUIP_DATA_COLLECT_DT DEFAULT (GETDATE()),

        CONSTRAINT PK_TB_EQUIP_DATA PRIMARY KEY CLUSTERED (DATA_ID)
    );
END
GO


/* ============================================================================
   5. TB_PARAM_LIMIT : 파라미터 임계치 규칙
   ----------------------------------------------------------------------------
   ※ EQUIP_ID는 설비 식별 코드지만 외래키(FK)는 걸지 않습니다.
   ============================================================================ */
IF OBJECT_ID(N'dbo.TB_PARAM_LIMIT', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TB_PARAM_LIMIT
    (
        LIMIT_ID     BIGINT         IDENTITY(1,1) NOT NULL,   -- 임계치 규칙 번호
        EQUIP_ID     NVARCHAR(200)  NOT NULL,                 -- 설비 식별 코드 (FK 없음)
        PARAM_NAME   NVARCHAR(200)  NOT NULL,                 -- 측정 파라미터 (TEMP, PRESSURE)
        LOWER_LIMIT  FLOAT          NOT NULL,                 -- 정상 하한값 (예: 20.0)
        UPPER_LIMIT  FLOAT          NOT NULL,                 -- 정상 상한값 (예: 80.0)
        CREATE_DT    DATETIME       NULL                      -- 룰 등록 일시
            CONSTRAINT DF_TB_PARAM_LIMIT_CREATE_DT DEFAULT (GETDATE()),

        CONSTRAINT PK_TB_PARAM_LIMIT PRIMARY KEY CLUSTERED (LIMIT_ID)
    );
END
GO


/* ============================================================================
   6. 설비 기초 마스터 데이터 등록 (4건)
   ----------------------------------------------------------------------------
   ※ 재실행 시 PK 중복 오류가 날 수 있으므로, 필요하면 1회만 실행하거나
      기존 데이터를 삭제 후 실행하세요.
   ============================================================================ */
INSERT INTO dbo.TB_EQUIPMENT (EQUIP_ID, EQUIP_NAME, LINE_NAME, STATUS, CREATE_DT)
VALUES
    (N'EQP-001', N'프레스 설비',     N'LINE-A', N'IDLE', GETDATE()),
    (N'EQP-002', N'로봇 팔레타이저', N'LINE-A', N'RUN',  GETDATE()),
    (N'EQP-003', N'컨베이어 모터',   N'LINE-B', N'IDLE', GETDATE()),
    (N'EQP-004', N'용접 로봇',       N'LINE-B', N'RUN',  GETDATE());
GO


/* ============================================================================
   7. 초기 가동 및 알람 로그 등록 (샘플 4건)
   ============================================================================ */

-- 설비 등록 완료 (INFO)
INSERT INTO dbo.TB_EQUIP_LOG (EQUIP_ID, LOG_TYPE, LOG_MSG, OCCUR_DT)
VALUES (N'EQP-001', N'INFO', N'설비 등록 완료', '2026-09-13 09:00:00');

-- 가동 시작 (STATUS_CHG)
INSERT INTO dbo.TB_EQUIP_LOG (EQUIP_ID, LOG_TYPE, LOG_MSG, OCCUR_DT)
VALUES (N'EQP-001', N'STATUS_CHG', N'가동 시작 (IDLE -> RUN)', '2026-09-13 09:05:00');

-- 모터 과열 (ALARM)
INSERT INTO dbo.TB_EQUIP_LOG (EQUIP_ID, LOG_TYPE, LOG_MSG, OCCUR_DT)
VALUES (N'EQP-002', N'ALARM', N'모터 과열 경보', '2026-09-13 09:10:00');

-- 설비 등록 완료 (INFO)
INSERT INTO dbo.TB_EQUIP_LOG (EQUIP_ID, LOG_TYPE, LOG_MSG, OCCUR_DT)
VALUES (N'EQP-003', N'INFO', N'설비 등록 완료', '2026-09-13 09:15:00');
GO


/* ============================================================================
   8. 조회 및 정합성 검증 (전체 조회)
   ============================================================================ */

-- 8-1. 전체 설비 조회
SELECT EQUIP_ID, EQUIP_NAME, LINE_NAME, STATUS, CREATE_DT
FROM dbo.TB_EQUIPMENT
ORDER BY EQUIP_ID;
GO

-- 8-2. 전체 로그 조회
SELECT LOG_ID, EQUIP_ID, LOG_TYPE, LOG_MSG, OCCUR_DT
FROM dbo.TB_EQUIP_LOG
ORDER BY LOG_ID;
GO
