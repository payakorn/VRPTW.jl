# using SMTPClient
function sent_email(subject::String, massage::String)
    username = "payakorn.sak@gmail.com"
    opt = SendOptions(
    isSSL = true,
    username = "payakorn.sak@gmail.com",
    passwd = "daxdEw-kyrgap-2bejge")
    #Provide the message body as RFC5322 within an IO
    body = IOBuffer(
    # "Date: Fri, 18 Oct 2013 21:44:29 +0100\r\n" *
    "From: You <$username>\r\n" *
    "To: payakornn@gmail.com\r\n" *
    "Subject: $subject\r\n" *
    "\r\n" *
    "$massage\r\n")
    url = "smtps://smtp.gmail.com:465"
    rcpt = ["<payakornn@gmail.com>"]
    from = "<$username>"
    resp = send(url, rcpt, from, body, opt)
end