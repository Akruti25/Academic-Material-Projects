import { Route, Routes, BrowserRouter } from "react-router-dom";
import { useEffect } from "react";
import { useStateValue } from "./StateProvider";
import { Login, SignUp } from "./Components/auth";
import ForgotPassword from "./Components/auth/ForgotPassword";
import ChangePassword from "./Components/auth/ChangePassword";
import LandingPage from "./Components/LandingPage/LandingPage";
import { initialState } from "./reducer";
import Recipes from "./Components/Recipes";
import RecipeRecommendations from "./Components/RecipeRecommendations";
import NavBar from "./Components/Navbar";
import Order from "./Components/Order";
import { useState } from "react";

function App() {
  const [
    {
      token,
      user: { role },
    },
    dispatch,
  ] = useStateValue();

  useEffect(() => {
    const authStateChange = setInterval(() => {
      const sessionToken = localStorage.getItem("token");
      const user = JSON.parse(localStorage.getItem("user"));
      if (sessionToken !== null) {
        dispatch({ type: "SET_TOKEN", token: sessionToken });
        dispatch({ type: "SET_USER", user });
      } else {
        dispatch({ type: "SET_TOKEN", token: null });
        dispatch({ type: "SET_USER", user: initialState.user });
      }
    }, 5000);
    return () => {
      clearInterval(authStateChange);
      dispatch({ type: "SET_TOKEN", token: null });
      dispatch({ type: "SET_USER", user: initialState.user });
    };
    // eslint-disable-next-line
  }, []);
  return (
    <BrowserRouter>
      <NavBar />
      <Routes>
        <Route path="/">
          <Route index element={<LandingPage />} />
          <Route path="recipes" element={<Recipes />} />
          <Route path="login" element={<Login />} />
          <Route path="signup" element={<SignUp />} />
          <Route path="forgot-password" element={<ForgotPassword />} />
          <Route path="reset-password/:token" element={<ChangePassword />} />
          <Route path="recommendations" element={<RecipeRecommendations />} />
          <Route path="order" element={<Order />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
