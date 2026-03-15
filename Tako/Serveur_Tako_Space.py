from flask import Flask, request, jsonify
import os
import json
from groq import Groq
from graph import Graph
app = Flask(__name__)

from TakoAPIKey import api_key
client = Groq(api_key=api_key)

name_alerady_used = []

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

space_graph = Graph()

@app.route('/analyse', methods=['POST'])
def analyser_planete():
    data = request.json
    prompt_received = data.get("prompt", "")
    
    if name_alerady_used:
        prompt_received += f"\n\nCONTRAINTE STRICTE : Tu ne dois ABSOLUMENT PAS utiliser l'un de ces noms (ils existent déjà) : {', '.join(name_alerady_used)}."

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

        if "name" in IA_dictionary:
            name_alerady_used.append(IA_dictionary["name"])
            planet = IA_dictionary["name"]
            space_graph.add_node(planet)
            print(f"Nœud ajouté : {planet} | Graphe actuel : {space_graph.nodes()}")
            
        return jsonify(IA_dictionary)

    except Exception as e:
        print(f"Marche pas, erreur : {e}")
        return jsonify({"erreur": str(e)}), 500

@app.route('/clear', methods=['POST'])
def clear_memory():
    global space_graph
    name_alerady_used.clear()
    print("Bip Boop... Mémoire des planètes EFFACÉE !")
    space_graph = Graph()
    return jsonify({"status": "Memoire vide"})

@app.route('/link', methods=['POST'])
def lier_planetes():
    data = request.json
    Planet_A = data.get("planet_A")
    Planet_B = data.get("planet_B")
    
    if Planet_A and Planet_B :
        space_graph.add_edge(Planet_A, Planet_B )
        
        print("-" * 50)
        print(f"Nouvelle liaison : {Planet_A} <---> {Planet_B }")
        print(f"Réseau galactique actuel : {space_graph.edges()}")
        
        return jsonify({"status": "Liaison enregistrée avec succès"})
    else:
        return jsonify({"erreur": "Il manque une planète pour faire le lien !"}), 400

@app.route('/neighbors', methods=['POST'])
def get_voisins():
    data = request.json
    name_planet = data.get("planet")
    
    if name_planet and space_graph.has_node(name_planet):
        copains = space_graph.neighbors(name_planet)
        return jsonify({"neighbors": copains})
    else:
        return jsonify({"neighbors": []})

if __name__ == '__main__':
    print("Le serveur de Tako est opérationnel ! En attente de signaux Godot...")
    app.run(port=8000)