import {
  Button,
  Card,
  CardContent,
  Container,
  TextField,
  Typography,
} from "@mui/material";
import { useState } from "react";
import { server } from "../../utils";

const ForgotPassword = () => {
  const [email, setEmail] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();

    server
      .post("/auth/forgot-password", { email })
      .then(({ data }) => {
        alert("An email has been sent to you. Please check your email.");
      })
      .catch((err) => console.log(err));
    setEmail("");
  };
  return (
    <Container maxWidth="xs">
      <Card>
        <CardContent>
          <Typography component="h1" variant="h5">
            Enter your email
          </Typography>
          <form noValidate onSubmit={handleSubmit}>
            <TextField
              variant="outlined"
              margin="normal"
              required
              fullWidth
              id="email"
              label="Email Address"
              name="email"
              autoComplete="email"
              autoFocus
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <Button type="submit" fullWidth variant="contained" color="primary">
              Send
            </Button>
          </form>
        </CardContent>
      </Card>
    </Container>
  );
};

export default ForgotPassword;
