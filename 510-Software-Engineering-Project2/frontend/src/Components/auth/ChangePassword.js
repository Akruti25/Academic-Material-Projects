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
import { useParams, useNavigate } from "react-router-dom";

const ChangePassword = () => {
  const { token } = useParams();
  const navigate = useNavigate();
  const [password, setPassword] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();

    server
      .post("/auth/change-password", { token, password })
      .then(({ data }) => {
        alert(data.msg);
        navigate.push("/login");
      })
      .catch((err) => console.log(err));
  };
  return (
    <Container component="main" maxWidth="xs">
      <Card>
        <CardContent>
          <Typography component="h1" variant="h5">
            Enter your new password
          </Typography>
          <form noValidate onSubmit={handleSubmit}>
            <TextField
              variant="outlined"
              margin="normal"
              required
              fullWidth
              name="password"
              label="Password"
              type="password"
              id="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            <Button type="submit" fullWidth variant="contained" color="primary">
              Submit
            </Button>
          </form>
        </CardContent>
      </Card>
    </Container>
  );
};

export default ChangePassword;
