from flask import Flask, request, jsonify
import os
import json
from groq import Groq

app = Flask(__name__)

from TakoAPIKey import api_key
client = Groq(api_key=api_key)

system_prompt = """Tu es Tako, un générateur de lore pour un jeu vidéo. 
Je vais te donner la description visuelle d'une planète. 
Tu dois inventer des informations fascinantes et cohérentes avec le visuel, soit créatif.
Tu dois OBLIGATOIREMENT répondre au format JSON strict avec ces 8 clés exactes :
"name" (ex: Zebulon-9), 
"type" (ex: Gazeuse, Tellurique, Cristalline, Artificielle, ect...),
"weight" (ex: 5.97 x 10^24 kg), 
"size" (ex: Rayon de 6371 km), 
"gravity" (ex: 1.2 G, Faible, ect...),
"habitable" (ex: Oui, Non, Sous conditions, ect...), 
"level of danger" (ex: Extrême, Modérée, Pacifique, ect...),
"description" (ex: Une phrase contenant des anecdote longue sur la planète).
N'ajoute aucun texte avant ou après le JSON et n'utilise aucun code hexadécimal dans ta réponsse."""

@app.route('/analyse', methods=['POST'])
def analyser_planete():
    data = request.json
    prompt_received = data.get("prompt", "")
    
    print("-" * 50)
    print(f"Reçu de Godot : {prompt_received}")
    
    try:
        response = client.chat.completions.create(
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt_received}
            ],
            model="llama-3.3-70b-versatile",
            response_format={"type": "json_object"} 
        )

        IA_texte = response.choices[0].message.content
        print(f"Réponse Tako : {IA_texte}")
        
        IA_dictionary = json.loads(IA_texte)
        return jsonify(IA_dictionary)

    except Exception as e:
        print(f"Marche pas, erreur : {e}")
        return jsonify({"erreur": str(e)}), 500

if __name__ == '__main__':
    print("Le serveur de Tako est opérationnel ! En attente de signaux Godot...")
    app.run(port=8000)