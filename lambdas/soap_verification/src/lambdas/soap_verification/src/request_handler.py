import logging
import xmltodict

def handle_request(event):
    
    # Extract the SOAP request from the event
    soap_request = event['body']

    # Parse the SOAP request
    soap_dict = xmltodict.parse(soap_request)

    soap_dict = strip_headers(soap_dict)

    # Extract the VIN number from the SOAP request
    vin = soap_dict["Envelope"]["Body"]["CoverageRequest"]["Detail"]["VehicleInformation"]["VehicleDetails"]["VIN"]

    # Extract Verification Date from the SOAP request
    verification_date = soap_dict["Envelope"]["Body"]["CoverageRequest"]["Detail"]["PolicyInformation"]["PolicyDetails"]["VerificationDate"]

    #Extract Tracking Number from the SOAP request
    tracking_number = soap_dict["Envelope"]["Body"]["CoverageRequest"]["RequestorInformation"]["ReasonDetails"]["TrackingNumber"]

    #Extract Policy Key from the SOAP request
    policy_key = soap_dict["Envelope"]["Body"]["CoverageRequest"]["Detail"]["PolicyInformation"]["PolicyDetails"]["PolicyKey"]


    # Logging the extracted values for debugging purposes
    logging.info(f"Extracted VIN: {vin}")
    logging.info(f"Extracted Verification Date: {verification_date}")
    logging.info(f"Extracted Tracking Number: {tracking_number}")
    logging.info(f"Extracted Policy Key: {policy_key}")


    return vin, verification_date, tracking_number, policy_key



def strip_headers(data):
    if isinstance(data, dict):
        return {
            key.split(":")[-1]: strip_headers(value)
            for key, value in data.items()
        }
    elif isinstance(data, list):
        return [strip_headers(item) for item in data]
    else:
        return data
