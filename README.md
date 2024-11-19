![image_021_0001](https://github.com/user-attachments/assets/55c8f6d5-275e-4414-ad52-121ee1e30f55)

# Keyhole Overlay Post Processing
![Unity Version](https://img.shields.io/badge/Unity-6000.0.27%27LTS%2B-blueviolet?logo=unity)
![Unity Pipeline Support (Built-In)](https://img.shields.io/badge/BiRP_❌-darkgreen?logo=unity)
![Unity Pipeline Support (URP)](https://img.shields.io/badge/URP_✔️-blue?logo=unity)
![Unity Pipeline Support (HDRP)](https://img.shields.io/badge/HDRP_❌-darkred?logo=unity)
 
A simple keyhole overlay effect, inspired by Dishonored's Peeping keyhole mechanic. It was created for Unity URP (6000.0.27f1) and for Serious Point Games as part of my studies in shader development.
It could theoretically run on Unity 2022 since its using the same code I used for the effects's render feature and pass within Unity 2022, but it is untested.

The effect was built on top of the transition post processing code I have, You can refer to it at [Github Repo Link](https://github.com/Josephy5/Transition-Post-Processing)

## Features
- Create keyhole overlays with a slight blur to the keyhole edges
- Can use custom keyhole textures to have unique keyhole overlays
- Can fade the keyhole overlay in or out
- Can adjust its cutout values to determine how much is cut out or be used as a transition

## Example[s]
![image_021_0001](https://github.com/user-attachments/assets/e668f339-713c-4455-a8d0-a22f7eef8b66)
The Keyhole Overlay effect

## Installation
1. Clone repo or download the folder and load it into an unity project.
2. Ensure that under the project settings > graphics > Render Graph, you enable Compatibility Mode on (meaning you have Render Graph Disabled).
3. Add the render feature of the effect to the Universal Renderer Data you are using.
4. Create a volume game object and load the effect's volume component in the volume profile to adjust values
5. If needed, you can change the effect's render pass event in its render feature under settings.

## Credits/Assets used
Some of the shader code is based from Dan Moran's Shaders Case Study—Pokémon Battle Transitions YouTube video
[-Youtube Video Link-](https://youtu.be/LnAoD7hgDxw?si=tCtTEOshaZdfLi6R).
