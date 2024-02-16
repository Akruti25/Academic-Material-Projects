export const initialState = {
  token: localStorage.getItem("token") || null,
  user: localStorage.getItem("user") || {
    role: null,
    _id: null,
    managedBy: null,
  },
  cart: [],
  recommendations: []
};

function reducer(state, action) {
  switch (action.type) {
    case "SET_TOKEN":
      return {
        ...state,
        token: action.token,
      };
    case "SET_USER":
      return {
        ...state,
        user: action.user,
      };
    case "SET_CART":
      return {
        ...state,
        cart: action.cart,
      };
    case "SET_RECOMMENDATIONS":
    return {
      ...state,
      recommendations: action.recommendations,
    };
    default:
      return state;
  }
}

export default reducer;
