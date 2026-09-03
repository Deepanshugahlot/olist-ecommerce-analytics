import os
import pandas as pd
from sqlalchemy import create_engine

# Database configuration
DB_USER = os.getenv("OLIST_DB_USER")
DB_PASSWORD = os.getenv("OLIST_DB_PASSWORD")
DB_HOST = os.getenv("OLIST_DB_HOST", "localhost")
DB_NAME = os.getenv("OLIST_DB_NAME", "ecommerce_project")

# Dataset directory
DATA_DIR = os.getenv("OLIST_DATA_DIR")

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:3306/{DB_NAME}"
)


def import_orders():
    orders = pd.read_csv(
        os.path.join(DATA_DIR, "olist_orders_dataset.csv")
    )

    print("\nOrders Dataset Preview:\n")
    print(orders.head())

    print("\nDataset Shape:")
    print(orders.shape)

    print("\nColumn Names:")
    print(orders.columns)

    print("\nData Types:")
    print(orders.dtypes)

    print("\nMissing Values:")
    print(orders.isnull().sum())

    date_columns = [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date"
    ]

    orders[date_columns] = orders[date_columns].apply(pd.to_datetime)

    print("\nUpdated Data Types:")
    print(orders.dtypes)

    print("\nMissing Values After Conversion:")
    print(orders[date_columns].isnull().sum())

    orders.to_sql(
        name="orders",
        con=engine,
        if_exists="append",
        index=False
    )

    print("\nOrders imported successfully!")


def import_products():
    products = pd.read_csv(
        os.path.join(DATA_DIR, "olist_products_dataset.csv")
    )

    print("\nProducts Dataset Preview:\n")
    print(products.head())

    print("\nDataset Shape:")
    print(products.shape)

    print("\nColumn Names:")
    print(products.columns)

    print("\nData Types:")
    print(products.dtypes)

    print("\nMissing Values:")
    print(products.isnull().sum())

    products.to_sql(
        name="products",
        con=engine,
        if_exists="append",
        index=False
    )

    print("\nProducts imported successfully!")


def import_sellers():
    sellers = pd.read_csv(
        os.path.join(DATA_DIR, "olist_sellers_dataset.csv")
    )

    print("\nSellers Dataset Preview:\n")
    print(sellers.head())

    print("\nDataset Shape:")
    print(sellers.shape)

    print("\nColumn Names:")
    print(sellers.columns)

    print("\nData Types:")
    print(sellers.dtypes)

    print("\nMissing Values:")
    print(sellers.isnull().sum())

    sellers.to_sql(
        name="sellers",
        con=engine,
        if_exists="append",
        index=False
    )

    print("\nSellers imported successfully!")


def import_order_payments():
    order_payments = pd.read_csv(
        os.path.join(DATA_DIR, "olist_order_payments_dataset.csv")
    )

    print("\nOrder Payments Dataset Preview:\n")
    print(order_payments.head())

    print("\nDataset Shape:")
    print(order_payments.shape)

    print("\nColumn Names:")
    print(order_payments.columns)

    print("\nData Types:")
    print(order_payments.dtypes)

    print("\nMissing Values:")
    print(order_payments.isnull().sum())

    order_payments.to_sql(
        name="order_payments",
        con=engine,
        if_exists="append",
        index=False
    )

    print("\nOrder Payments imported successfully!")


def import_order_reviews():
    order_reviews = pd.read_csv(
        os.path.join(DATA_DIR, "olist_order_reviews_dataset.csv")
    )

    print("\nOrder Reviews Dataset Preview:\n")
    print(order_reviews.head())

    print("\nDataset Shape:")
    print(order_reviews.shape)

    print("\nColumn Names:")
    print(order_reviews.columns)

    print("\nData Types:")
    print(order_reviews.dtypes)

    print("\nMissing Values:")
    print(order_reviews.isnull().sum())

    date_columns = [
        "review_creation_date",
        "review_answer_timestamp"
    ]

    order_reviews[date_columns] = order_reviews[date_columns].apply(
        pd.to_datetime
    )

    order_reviews.to_sql(
        name="order_reviews",
        con=engine,
        if_exists="append",
        index=False
    )

    print("\nOrder Reviews imported successfully!")


def import_category_name_translation():
    category_name_translation = pd.read_csv(
        os.path.join(DATA_DIR, "product_category_name_translation.csv")
    )

    print("\nCategory Name Translation Dataset Preview:\n")
    print(category_name_translation.head())

    print("\nDataset Shape:")
    print(category_name_translation.shape)

    print("\nColumn Names:")
    print(category_name_translation.columns)

    print("\nData Types:")
    print(category_name_translation.dtypes)

    print("\nMissing Values:")
    print(category_name_translation.isnull().sum())

    category_name_translation.to_sql(
        name="product_category_name_translation",
        con=engine,
        if_exists="append",
        index=False
    )

    print("\nCategory Name Translation imported successfully!")


def import_geolocation():
    geolocation = pd.read_csv(
        os.path.join(DATA_DIR, "olist_geolocation_dataset.csv")
    )

    print("\nGeolocation Dataset Preview:\n")
    print(geolocation.head())

    print("\nDataset Shape:")
    print(geolocation.shape)

    print("\nColumn Names:")
    print(geolocation.columns)

    print("\nData Types:")
    print(geolocation.dtypes)

    print("\nMissing Values:")
    print(geolocation.isnull().sum())

    geolocation.to_sql(
        name="geolocation",
        con=engine,
        if_exists="append",
        index=False
    )

    print("\nGeolocation imported successfully!")


def import_order_items():
    order_items = pd.read_csv(
        os.path.join(DATA_DIR, "olist_order_items_dataset.csv")
    )

    print("\nOrder Items Dataset Preview:\n")
    print(order_items.head())

    print("\nDataset Shape:")
    print(order_items.shape)

    print("\nColumn Names:")
    print(order_items.columns)

    print("\nData Types:")
    print(order_items.dtypes)

    print("\nMissing Values:")
    print(order_items.isnull().sum())

    date_columns = [
        "shipping_limit_date"
    ]

    order_items[date_columns] = order_items[date_columns].apply(
        pd.to_datetime
    )

    order_items.to_sql(
        name="order_items",
        con=engine,
        if_exists="append",
        index=False
    )

    print("\nOrder Items imported successfully!")