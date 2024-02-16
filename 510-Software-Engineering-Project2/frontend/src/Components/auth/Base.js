import {
  Button,
  Card,
  CardContent,
  CardHeader,
  TextField,
  Typography,
} from "@mui/material";
import { Box } from "@mui/system";
import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useStateValue } from "../../StateProvider";
import { server } from "../../utils";

const Base = ({ isLogin }) => {
  const [, dispatch] = useStateValue();
  const navigate = useNavigate();
  const [state, setState] = useState({
    name: "",
    email: "",
    password: "",
  });

  const registerOrLoginWithEmail = (e) => {
    e.preventDefault();
    server
      .post(`/auth/${isLogin ? "signin" : "signup"}`, {
        ...state,
      })
      .then(({ data: { token, user } }) => {
        console.log(token, user);
        localStorage.setItem("token", token);
        localStorage.setItem("user", JSON.stringify(user));

        dispatch({ type: "SET_TOKEN", token });
        dispatch({ type: "SET_USER", user });

        navigate("/");
      })
      .catch((err) => alert(err.response.data.error));
  };

  const handleChange = (e) => {
    setState((prevState) => {
      return { ...prevState, [e.target.name]: e.target.value };
    });
  };
  return (
    <Box
      sx={{
        width: { xs: 300, md: 500 },
        position: "absolute",
        top: "50%",
        left: "50%",
        transform: "translate(-50%, -50%)",
      }}
    >
      <Card>
        <CardHeader title={isLogin ? "Log In" : "Sign Up"} />
        <CardContent>
          <form noValidate onSubmit={registerOrLoginWithEmail}>
            {!isLogin && (
              <TextField
                name="name"
                placeholder="Name"
                variant="standard"
                onChange={handleChange}
                style={{ width: "100%" }}
              />
            )}
            <TextField
              name="email"
              placeholder="Email"
              type="email"
              variant="standard"
              onChange={handleChange}
              style={{ width: "100%", marginTop: "2vh" }}
            />
            <TextField
              name="password"
              placeholder="Password"
              type="password"
              variant="standard"
              onChange={handleChange}
              style={{ width: "100%", marginTop: "2vh" }}
            />
            {isLogin && (
              <Link to="/forgot-password">
                <Typography
                  style={{ width: "100%", marginTop: "2vh" }}
                  variant="body2"
                >
                  Forgot Password?
                </Typography>
              </Link>
            )}
            <div
              style={{
                display: "flex",
                justifyContent: "space-evenly",
                marginTop: "2vh",
              }}
            >
              <Button type="submit">{isLogin ? "Log In" : "Register"}</Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </Box>
  );
};

export default Base;
