# +
*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Resource          Keywords.robot
Library           RPA.Browser.Selenium
Library           RPA.Excel.Files
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Dialogs
Library           RPA.Robocloud.Secrets
# -

*** Variables ***
${GLOBAL_RETRY_AMOUNT}=    10x
${GLOBAL_RETRY_INTERVAL}=    1s
${RECEIPT_FOLDER}=    ${OUTPUT_DIR}/receipts
${order_number}
${CSV_URL}=           https://robotsparebinindustries.com/orders.csv

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
     Get the URL and Open the robot order website
    ${orders} =    Get orders   ${CSV_URL}
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts
    [Teardown]      Close Browser
