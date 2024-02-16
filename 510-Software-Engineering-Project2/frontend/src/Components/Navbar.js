import { Restaurant } from "@mui/icons-material";
import { AppBar, IconButton, Toolbar, Typography, Button,ListItem,
  ListItemIcon,
  ListItemText } from "@mui/material";

import { useStateValue } from "../StateProvider";
import CreateIcon from "@mui/icons-material/Create";
import VpnKeyIcon from "@mui/icons-material/VpnKey";
import { useNavigate } from "react-router-dom";
import ExitToAppIcon from "@mui/icons-material/ExitToApp";
import { initialState } from "../reducer";


const NavBar = () => {
  const navigate = useNavigate();
  const [
    {
      token
    },
    dispatch,
  ] = useStateValue();

  const menuItems = [
    {
      listIcon: <CreateIcon style ={{color:"white", margin: "2px"}} />,
      listText: "Register",
      to: "/signup",
      display: !token,
    },
    {
      listIcon: <VpnKeyIcon style ={{color:"white"}}/>,
      listText: "Login",
      to: "/login",
      display: !token,
    }
  ]

  return (
    <div>
      <AppBar position="sticky" style={{ background: "#022950" }}>
        <Toolbar>
          <Button style={{textTransform: "capitalize"}} onClick={() => navigate("/")}>
          <IconButton>
            <Restaurant fontSize="large" style={{ color: "white" }} />
          </IconButton> </Button>
          
          <Typography
            style={{
              flexGrow: 1,
              color: "white",
              cursor:"pointer"
              
            }}
            
            onClick={() => navigate("/")}
            variant="h5"
          >
           The CookBook
          </Typography>
         
          
           
          {menuItems.map(
              (listItem, key) =>
                listItem.display && (
                  <ListItem style = {{width: 'min-content'}}
                    button
                    key={key}
                    onClick={() => {
                      navigate(listItem.to);
                      window.scrollTo(0, 0);
                    }}
                  >
                    <ListItemIcon style ={{margin:"0 -20px 0 20px"}}>{listItem.listIcon}</ListItemIcon>
                    <ListItemText>
                      <b>{listItem.listText}</b>
                    </ListItemText>
                  </ListItem>
                )
            )}
        {token && (
              <ListItem  style = {{width: 'min-content'}}
                button
                onClick={() => {
                  localStorage.removeItem("token");
                  localStorage.removeItem("user");
                  dispatch({ type: "SET_TOKEN", token: null });
                  dispatch({ type: "SET_CART", cart: {} });
                  dispatch({ type: "SET_USER", user: initialState.user });
                  navigate("/");
                }}
              >
                <ListItemIcon style ={{margin:"0 -20px"}}>
                  <ExitToAppIcon style ={{color:"white"}}/>
                </ListItemIcon>
                <ListItemText>
                  <b>Logout</b>
                </ListItemText>
              </ListItem>
            )}
        </Toolbar>
      </AppBar>
    </div>
  );
};

export default NavBar;
