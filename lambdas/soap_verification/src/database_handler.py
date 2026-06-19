from rds_iam_auth import get_rds_iam_connection

def database_connection():
    return get_rds_iam_connection()

def query_policy_info_by_vin(vin_number, verification_date):
    connection = database_connection()
    cursor = connection.cursor()

    query = """
    SELECT
    p.policy_number,
    au.unit_added_date,
    au.unit_expiration_date,
    p.job_description,
    u.unit_number,
    au.vehicle_identification_number
    FROM public.auto_unit au
    JOIN public.unit u
    ON u.unit_id = au.unit_id
    JOIN public.policy p
    ON p.policy_id = u.policy_id
    WHERE
    au.vehicle_identification_number = %s
    AND %s BETWEEN au.unit_added_date AND au.unit_expiration_date
    AND au.unit_added_date IS NOT NULL
    AND au.unit_expiration_date IS NOT NULL
    ORDER BY au.unit_added_date DESC
    LIMIT 1;
    """



    cursor.execute(query, (vin_number,verification_date))
    result = cursor.fetchone()

    # Get Column Names
    column_names = [desc[0] for desc in cursor.description]

    cursor.close()
    connection.close()

    if result:
        # Convert tuple to dictionary for better handling
        return dict(zip(column_names, result))
    else:
        return None



    
