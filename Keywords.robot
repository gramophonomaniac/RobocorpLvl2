# +
*** Keywords ***
Get the URL and Open the robot order website
  ${url}=    Get Secret    website
    Open Available Browser    ${url}[url]
    Maximize Browser Window

    Add text input    url    label=input CSV URL
    ${response}=      Run dialog

    [Return]    ${response.url}

Get orders
    [Arguments]    ${CSV_URL}

    Download      ${CSV_URL}             overwrite=True
    ${orders}=    Read table from CSV    orders.csv    header=True

    [Return]    ${orders}


Close the annoying modal
    Click Button    OK

Fill the form
    [Arguments]    ${rows}
    ${head}=    Convert To Integer    ${rows}[Head]
    ${body}=    Convert To Integer    ${rows}[Body]
    ${legs}=    Convert To Integer    ${rows}[Legs]
    ${address}=    Convert To String    ${rows}[Address]
    Select From List By Value   id:head   ${head}
    Click Element   id-body-${body}
    Input Text      id:address    ${address}
    Input Text      xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${legs}

Preview the robot
    Click Element    id:preview
    Wait Until Element Is Visible    id:robot-preview

Submit the order
    Wait Until Keyword Succeeds     ${GLOBAL_RETRY_AMOUNT}      ${GLOBAL_RETRY_INTERVAL}    Submit the order And Keep Checking Until Success

Submit the order And Keep Checking Until Success
    Click Element    order
    Element Should Be Visible    xpath://div[@id="receipt"]/p[1]
    Element Should Be Visible    id:order-completion
    
Store the receipt as a PDF file
    [Arguments]    ${order_number}
    Wait Until Element Is Visible    id:order-completion
    ${order_number}=    Get Text    xpath://div[@id="receipt"]/p[1]
    #Log    ${order_number}
    ${receipt_html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${receipt_html}    ${CURDIR}${/}output${/}receipts${/}${order_number}.pdf
    [Return]    ${CURDIR}${/}output${/}receipts${/}${order_number}.pdf
   

Take a screenshot of the robot
   [Arguments]    ${order_number}
    Screenshot     id:robot-preview    ${CURDIR}${/}output${/}${order_number}.png
    [Return]       ${CURDIR}${/}output${/}${order_number}.png
    
Embed the robot screenshot to the receipt PDF file 
    [Arguments]    ${screenshot}   ${pdf}
    Open Pdf       ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Close Pdf      ${pdf}
    
Go to order another robot
    Click Button    order-another
    
Create a ZIP file of the receipts
    Archive Folder With Zip  ${CURDIR}${/}output${/}receipts   ${CURDIR}${/}output${/}receipt.zip
    
    
