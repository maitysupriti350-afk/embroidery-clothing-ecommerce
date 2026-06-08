import sys
import io

# Force UTF-8 output encoding so emoji characters print correctly on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

from sqlalchemy import create_engine
import pandas as pd

def generate_sales_report():
    try:
        # 1. Connect to your local MySQL database using SQLAlchemy engine
        engine = create_engine("mysql+mysqlconnector://root:admin123@localhost/clothing_db")
        
        # 2. SQL Query matching your exact orders table columns (o_id, user_id, total_amount, status)
        query = """
        SELECT 
            o_id AS order_id, 
            user_id AS customer_id, 
            total_amount AS revenue, 
            status AS order_status,
            payment_method
        FROM orders;
        """
        
        # 3. Read the data directly from MySQL into a pandas DataFrame (no warning with SQLAlchemy)
        df = pd.read_sql(query, engine)
        
        print("\n--- \U0001f4c8 CLOTHING STORE SALES ANALYTICS REPORT ---")
        
        # 4. Check if data exists and display results
        if df.empty:
            print("No sales data recorded yet. Make sure you have inserted data into the 'orders' table!")
        else:
            print("\n", df.to_string(index=False))
            
            # 5. Advanced Analysis: Calculate total revenue and average order size using Pandas
            total_sales_revenue = df['revenue'].sum()
            average_order_value = df['revenue'].mean()
            
            print(f"\n\U0001f4ca --- Business Insights ---")
            print(f"\U0001f4b0 Total Revenue Generated: \u20b9{total_sales_revenue:.2f}")
            print(f"\U0001f6cd\ufe0f Average Customer Order Value: \u20b9{average_order_value:.2f}")
        
        # Dispose the engine (closes all pooled connections)
        engine.dispose()
        
    except Exception as e:
        print(f"\u274c Error: {e}")

if __name__ == "__main__":
    generate_sales_report()
