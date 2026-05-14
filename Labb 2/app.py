from sqlalchemy import create_engine, text

CONNECTION_STRING = "mssql+pyodbc://@localhost\SQLEXPRESS/Bokhandel?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"

def main():
    try:
        engine = create_engine(CONNECTION_STRING)
        
        while True:
            sokord = input("\nAnge boktitel att söka efter (eller 'avsluta' för att stänga): ")
            
            if sokord.lower() == 'avsluta':
                break
                
            query = text("""
                SELECT Böcker.Titel, Butiker.Butiksnamn, LagerSaldo.Antal
                FROM Böcker
                JOIN LagerSaldo ON Böcker.ISBN13 = LagerSaldo.ISBN
                JOIN Butiker ON LagerSaldo.ButikID = Butiker.ID
                WHERE Böcker.Titel LIKE :sokord
            """)
            
            with engine.connect() as connect:
                result = connect.execute(query, {"sokord": f"%{sokord}%"})
                
                rows = result.fetchall()
                if not rows:
                    print("Inga böcker matchade din sökning.")
                else:
                    print(f"\n--- Sökresultat för '{sokord}' ---")
                    for row in rows:
                        print(f"Bok: {row.Titel} | Butik: {row.Butiksnamn} | Antal: {row.Antal} st")

    except Exception as e:
        print(f"Ett fel uppstod: {e}")

if __name__ == "__main__":
    main()