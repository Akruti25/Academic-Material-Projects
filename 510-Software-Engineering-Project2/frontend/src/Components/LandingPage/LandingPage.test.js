import { render, screen } from "@testing-library/react";
import LandingPage from "./LandingPage";

test("renders learn react link", () => {
  render(<LandingPage />);
  const linkElement = screen.getByText(
    /Turn your ingredients into delicious recipes/i
  );
  expect(linkElement).toBeInTheDocument();
});
