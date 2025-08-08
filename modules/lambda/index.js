const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const nodemailer = require('nodemailer');

const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  console.log("Request received:", JSON.stringify(event));

  let body;
  try {
    body = JSON.parse(event.body);
  } catch (err) { 
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Invalid JSON' })
    };
  }

  const message = body.message;

  if (!message || message.trim() === "") {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Message is required' })
    };
  }

  const params = {
    TableName: process.env.TABLE_NAME,
    Item: {
      id: uuidv4(),
      message,
      timestamp: new Date().toISOString()
    }
  };

  try {
    await dynamodb.put(params).promise();
  } catch (error) {
    console.error("DynamoDB error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Could not write to DynamoDB' })
    };
  }

  // === AJOUT : envoi d'e-mail ===
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });

  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: process.env.EMAIL_RECEIVER,
    subject: 'Nouveau message reçu via Lambda',
    text: `Message: ${message}`
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log("Email sent");
  } catch (err) {
    console.error("Email error:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'DynamoDB OK, email failed to send' })
    };
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ success: true, message: 'Saved to DynamoDB and email sent' })
  };
};
