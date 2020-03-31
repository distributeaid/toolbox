import React from "react";
import { Button } from "../components/Button";
import { Input } from "../components/Input";
import { Checkbox } from "../components/Checkbox";
import { Divider } from "../components/Divider";

const StyleGuide: React.FC = () => (
  <div className="m-10">
    <Divider outerClasses="m-4">A Divider, margin: m-4</Divider>

    <Button title="Default Button" />

    <Divider outerClasses="m-4">A Divider, margin: m-4</Divider>

    <Checkbox title="A Checkbox" id="checkbox" />

    <Divider outerClasses="m-4">A Divider, margin: m-4</Divider>

    <Input
      id="demo"
      type="text"
      title="Input, type: text"
      onChange={event => null}
    />
  </div>
);

export default StyleGuide;
