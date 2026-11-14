import nodemailer from 'nodemailer';

const transport = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'mailhog',
  port: Number(process.env.SMTP_PORT || 1025),
  secure: false,
});

export function sendMail({ to, subject, text }) {
  return transport.sendMail({
    from: process.env.MAIL_FROM || 'shop@vibeshop.test',
    to,
    subject,
    text,
  });
}
