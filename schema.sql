-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

-- Create relevant tables
CREATE TABLE "journal_transactions" (
    "id" INTEGER,
    "memo" TEXT NOT NULL,
    "amount" NUMERIC CHECK("amount"<>0) NOT NULL,
    "GL_id" INTEGER NOT NULL,
    "date_id" INTEGER NOT NULL,
    "country_id" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("GL_id") REFERENCES "GL_accounts"("id"),
    FOREIGN KEY("date_id") REFERENCES "dates"("id"),
    FOREIGN KEY("country_id") REFERENCES "countries"("id")
);

CREATE TABLE "GL_accounts" (
    "id" INTEGER,
    "GL_L1" TEXT NOT NULL,
    "GL_L2" TEXT NOT NULL,
    "GL_L3" TEXT NOT NULL,
    "FS_id" INTEGER NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("FS_id") REFERENCES "FS_categories"("id")
);

CREATE TABLE "FS_categories" (
    "id" INTEGER,
    "type" TEXT CHECK("type" IN ('income statement', 'balance sheet')) NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "dates" (
    "id" INTEGER,
    "date" NUMERIC NOT NULL,
    "year" INTEGER NOT NULL,
    "month" INTEGER NOT NULL,
    "day" INTEGER NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "countries" (
     "id" INTEGER,
     "country" TEXT NOT NULL,
     PRIMARY KEY("id")
);


-- Insert values

INSERT INTO "FS_categories" ("id", "type")
VALUES
(1, 'income statement'),
(2, 'balance sheet')
;


INSERT INTO "countries" ("id", "country")
VALUES
(1, 'Philippines'),
(2, 'United States'),
(3, 'China')
;


-- Insert csv into tables
-- .import --csv --skip 1 dates.csv "dates"
-- .import --csv --skip 1 GL.csv "GL_accounts"
-- .import --csv --skip 1 journal.csv "journal_transactions"


-- Create views
CREATE VIEW "income_statement" AS
SELECT
"country",
"GL_L1",
"GL_L2",
"GL_L3",
SUM("amount") AS "amount",
"year",
"month"
FROM "GL_accounts" JOIN "journal_transactions" ON "GL_accounts"."id" = "journal_transactions"."GL_id"
JOIN "dates" ON "dates"."id" = "journal_transactions"."date_id"
JOIN "FS_categories" ON "FS_categories"."id" = "GL_accounts"."FS_id"
JOIN "countries" ON "countries"."id" = "journal_transactions"."country_id"
WHERE
"FS_categories"."type" = 'income statement'
GROUP BY "GL_L1", "year", "month", "country"
ORDER BY "GL_accounts"."id"
;

CREATE VIEW "balance_sheet" AS
SELECT
"country",
"GL_L1",
"GL_L2",
"GL_L3",
SUM("amount") AS "amount",
"year",
"month"
FROM "GL_accounts" JOIN "journal_transactions" ON "GL_accounts"."id" = "journal_transactions"."GL_id"
JOIN "dates" ON "dates"."id" = "journal_transactions"."date_id"
JOIN "FS_categories" ON "FS_categories"."id" = "GL_accounts"."FS_id"
JOIN "countries" ON "countries"."id" = "journal_transactions"."country_id"
WHERE
"FS_categories"."type" = 'balance sheet'
GROUP BY "GL_L1", "year", "month", "country"
ORDER BY "GL_accounts"."id"
;


-- Update journal amounts to follow reporting balances (not normal balances)
-- Assets(+) Liabilities(+) Equity(+) Revenue(+) Expenses(-)
-- made an exception for revenue and expense normal balance for reporting purposes
UPDATE "journal_transactions" SET "amount" = "amount" * -1
WHERE SUBSTR("GL_id",1,1) IN ('5');


-- Optimize queries by creating indexes
CREATE INDEX "journal_GL" ON "journal_transactions"("GL_id");
CREATE INDEX "journal_date" ON "journal_transactions"("date_id");
CREATE INDEX "journal_country" ON "journal_transactions"("country_id");
CREATE INDEX "date" ON "dates"("year","month");
CREATE INDEX "country" ON "countries"("country");
