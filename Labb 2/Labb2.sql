CREATE DATABASE Bokhandel;

GO

USE Bokhandel;

GO

CREATE TABLE Författare (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn VARCHAR(50) NOT NULL,
    Efternamn VARCHAR(50) NOT NULL,
    Födelsedatum DATE NOT NULL
);

CREATE TABLE Förlag (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Namn VARCHAR(100) NOT NULL
);

CREATE TABLE Butiker (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Butiksnamn VARCHAR(50) NOT NULL,
    Adress VARCHAR(100) NOT NULL,
    Stad VARCHAR(50) NOT NULL
);

CREATE TABLE Böcker (
    ISBN13 VARCHAR(13) PRIMARY KEY,
    Titel VARCHAR(100) NOT NULL,
    Språk VARCHAR(30) NOT NULL,
    Pris DECIMAL(10,2) NOT NULL,
    Utgivningsdatum DATE NOT NULL,
    FörfattareID INT NOT NULL FOREIGN KEY REFERENCES Författare(ID),
    FörlagID INT NOT NULL FOREIGN KEY REFERENCES Förlag(ID) 
);

CREATE TABLE Anställda (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn VARCHAR(50) NOT NULL,
    Efternamn VARCHAR(50) NOT NULL,
    ButikID INT NOT NULL FOREIGN KEY REFERENCES Butiker(ID) 
);

CREATE TABLE LagerSaldo (
    ButikID INT FOREIGN KEY REFERENCES Butiker(ID),
    ISBN VARCHAR(13) FOREIGN KEY REFERENCES Böcker(ISBN13),
    Antal INT NOT NULL DEFAULT 0,
    PRIMARY KEY (ButikID, ISBN)
);

GO

INSERT INTO Förlag (Namn) VALUES 
('Bonnier'), ('Norstedts'), ('Liber');

INSERT INTO Författare (Förnamn, Efternamn, Födelsedatum) VALUES
('Astrid', 'Lindgren', '1907-11-14'),
('J.K.', 'Rowling', '1965-07-31'),
('Stephen', 'King', '1947-09-21'),
('Camilla', 'Läckberg', '1974-08-30');

INSERT INTO Butiker (Butiksnamn, Adress, Stad) VALUES
('Campusbokhandeln', 'Götabergsgatan 17', 'Göteborg'),
('Akademibokhandeln', 'Mäster Samuelsgatan 28', 'Stockholm'),
('Adlibris', 'Södra Förstadsgatan 32', 'Malmö');

INSERT INTO Anställda (Förnamn, Efternamn, ButikID) VALUES
('Kalle', 'Svensson', 1), ('Anna', 'Berg', 2), ('Johan', 'Andersson', 3);

INSERT INTO Böcker (ISBN13, Titel, Språk, Pris, Utgivningsdatum, FörfattareID, FörlagID) VALUES
('9789129688313', 'Pippi Långstrump', 'Svenska', 149.00, '1945-11-26', 1, 1),
('9789129688320', 'Emil i Lönneberga', 'Svenska', 159.00, '1963-05-23', 1, 1),
('9789129688337', 'Bröderna Lejonhjärta', 'Svenska', 169.00, '1973-10-01', 1, 1),
('9789129688344', 'Harry Potter och de vises sten', 'Svenska', 199.00, '1999-01-01', 2, 2),
('9789129688351', 'Harry Potter och Hemligheternas kammare', 'Svenska', 199.00, '2000-01-01', 2, 2),
('9789129688368', 'The Shining', 'Engelska', 129.00, '1977-01-28', 3, 3),
('9789129688375', 'It', 'Engelska', 139.00, '1986-09-15', 3, 3),
('9789129688382', 'Isprinsessan', 'Svenska', 89.00, '2003-01-01', 4, 1),
('9789129688399', 'Predikanten', 'Svenska', 89.00, '2004-01-01', 4, 1),
('9789129688405', 'Stenhuggaren', 'Svenska', 89.00, '2005-01-01', 4, 1);

INSERT INTO LagerSaldo (ButikID, ISBN, Antal) VALUES
(1, '9789129688313', 10), (2, '9789129688313', 5), (3, '9789129688313', 2),
(1, '9789129688320', 4), (2, '9789129688320', 0), (3, '9789129688337', 8),
(1, '9789129688344', 15), (2, '9789129688344', 20), (3, '9789129688351', 5),
(1, '9789129688368', 3), (2, '9789129688375', 6), (3, '9789129688382', 12),
(1, '9789129688399', 7), (2, '9789129688405', 4), (3, '9789129688405', 1);

GO

CREATE VIEW TitlarPerFörfattare AS
SELECT 
    Författare.Förnamn + ' ' + Författare.Efternamn AS Namn,
    DATEDIFF(YEAR, Författare.Födelsedatum, GETDATE()) AS Ålder,
    COUNT(DISTINCT Böcker.ISBN13) AS Titlar,
    SUM(Böcker.Pris * LagerSaldo.Antal) AS Lagervärde
FROM Författare
JOIN Böcker ON Författare.ID = Böcker.FörfattareID
JOIN LagerSaldo ON Böcker.ISBN13 = LagerSaldo.ISBN
GROUP BY Författare.Förnamn, Författare.Efternamn, Författare.Födelsedatum;

GO