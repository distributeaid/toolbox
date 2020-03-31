import React from "react";
import { Button } from "../components/Button";
import { Input } from "../components/Input";
import { Checkbox } from "../components/Checkbox";
import { Divider } from "../components/Divider";
import { ContentContainer } from "../components/ContentContainer";

const StyleGuide: React.FC = () => (
  <ContentContainer>
    <div className="grid grid-cols-1 gap-4 m-16">
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
  </ContentContainer>
);

export default StyleGuide;
