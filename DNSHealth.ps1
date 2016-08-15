$TotalQueryRecieved = (get-counter -Counter "\DNS\Total Query Received").countersamples.cookedvalue
$QuerysRecievedPerSecond = (get-counter -Counter "\DNS\Total Response Sent").countersamples.cookedvalue
$TotalResponsesSent = (get-counter -Counter "\DNS\Total Query Received").countersamples.cookedvalue
$ResponcesSentPerSecond = (get-counter -Counter "\DNS\Total Query").countersamples.cookedvalue
