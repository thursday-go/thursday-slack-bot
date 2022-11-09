package main

import (
	"github.com/aws/aws-lambda-go/lambda"
)

func LambdaHandler() (int, error) {
	return 1, nil
}

func main() {
	lambda.Start(LambdaHandler)
}

// import (
// 	"fmt"
// 	"os"
// 	"time"

// 	"github.com/slack-go/slack"
// )

// var token = os.Getenv("SLACK_AUTH_TOKEN")
// var channelID = os.Getenv("SLACK_CHANNEL_ID")

// func main() {
// 	// api := slack.New(token, slack.OptionDebug(true))
// 	api := slack.New(token)

// 	attachment := slack.Attachment{
// 		Pretext: "Bot Message",
// 		Text:    "bot text",
// 		Color:   "4af030",
// 		Fields: []slack.AttachmentField{
// 			{
// 				Title: "Date",
// 				Value: time.Now().String(),
// 			},
// 		},
// 	}
// 	_, timestamp, err := api.PostMessage(
// 		channelID,
// 		slack.MsgOptionAttachments(attachment),
// 	)
// 	if err != nil {
// 		panic(err)
// 	}
// 	fmt.Printf("message sent at %s", timestamp)
// }
