import salad from "../imgs/salad.jpg";
import chopsuey from "../imgs/chopsuey.jpg";
import burger from "../imgs/burger.jpg";
import pizza from "../imgs/pizza.jpg";
import sushi from "../imgs/sushi.jpg";
import brownies from "../imgs/brownies.jpg";
import mocktail from "../imgs/mocktail.jpg";
import "./cards.css";
import * as React from "react";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import CardMedia from "@mui/material/CardMedia";
import Typography from "@mui/material/Typography";
import SearchBar from "./SearchBar";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { server } from "../utils";
import { useStateValue } from "../StateProvider";

const Recipes = () => {
  const navigate = useNavigate();
  const [, dispatch] = useStateValue();
  const arrayChunk = (arr, n) => {
    // console.log("array: ", arr);
    const array = arr.slice();
    const chunks = [];
    while (array.length) chunks.push(array.splice(0, n));
    return chunks;
  };
  const recipes = [
    { name: "Chopsuey", image: chopsuey, code: "6343589a540176212b44d4f8" },
    { name: "Grilled Burger", image: burger, code: "63435a92540176212b453037" },
    { name: "Brownies", image: brownies, code: "634358ab540176212b44d7c4" },
    { name: "Salmon Sushi", image: sushi, code: "63437b6c540176212b4ab6be" },
    { name: "Mocktail", image: mocktail, code: "634366f3540176212b471783" },
    { name: "Pizza", image: pizza, code: "63435966540176212b44f9af" },
    { name: "Chicken Salad", image: salad, code: "634358a4540176212b44d68c" },
    // { name: "Butter Chicken", image: butterChicken, code: "63435a69540176212b45289d" },
    // { name: "Chocolate Chip Cookies", image: cookies, code: "634360b3540176212b45ee4f" },
    // { name: "Thai Curry", image: curry, code: "63435a93540176212b453045" },
    // { name: "Chinese Fried Rice", image: rice, code: "6343599d540176212b450369" },
    // { name: "Vegetable Soup", image: soup, code: "634358f5540176212b44e529" },
  ];

  const filterData = (query, data) => {
    if (!query) {
      return data;
    } else {
      return data.filter((d) => d.name.toLowerCase().includes(query));
    }
  };
  const [searchQuery, setSearchQuery] = useState("");
  const dataFiltered = filterData(searchQuery, recipes);

  const getRecipeRecommendations = (recipe) => {
    server.get("/recommend/" + recipe)
    .then((data) =>{
        console.log("data", data.data.recommendations)
        dispatch({type: 'SET_RECOMMENDATIONS', recommendations: data.data.recommendations})
        navigate("/recommendations");
    })
    .catch((err) => alert(err.response.data.error));
  };
  return (
    <div>
      <div
        style={{
          margin: "50px auto",
          flexDirection: "column",
          overflow: "hidden",
        }}
      >
        <Typography variant="h3" component="h5" style={{ textAlign: "center" }}>
          Which dish do you like?
        </Typography>
        <Typography
          variant="h6"
          component="h6"
          style={{ textAlign: "center", color: "black", margin: "3px 310px" }}
        >
          Choose a recipe and we will give 10 recipe recommendations based on
          your choice.
        </Typography>
        <div style={{ display: "flex", justifyContent: "center" }}><SearchBar searchQuery={searchQuery} setSearchQuery={setSearchQuery} autoFocus /></div>
        <div style={{ display: "flex", justifyContent: "center" }}>
          {arrayChunk(...Array(dataFiltered), 12).map((row, i) => (
            <div
              key={i}
              className="row mx-auto"
              style={{ justifyContent: "center" }}
            >
              {row.map((col, i) => (
                <Card
                  onClick={() => getRecipeRecommendations(dataFiltered[i].code)}
                  className="card"
                  key={i}
                  sx={{ width: "25%", maxHeight: 225 }}
                  style={{ float: "left", margin: "20px 4%", fontSize: "12px" }}
                >
                  <CardMedia
                    component="img"
                    height="180"
                    image={dataFiltered[i].image}
                    alt={dataFiltered[i].name}
                  />
                  <CardContent>
                    <Typography
                      gutterBottom
                      variant="h6"
                      style={{ textAlign: "center", fontSize: "14px" }}
                    >
                      {dataFiltered[i].name}
                    </Typography>
                  </CardContent>
                </Card>
              ))}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Recipes;
