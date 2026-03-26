from flask import Flask, request, jsonify
import os
import json
from groq import Groq
from graph import Graph
app = Flask(__name__)

from TakoAPIKey import api_key, api_key_backup
client = Groq(api_key=api_key_backup) #or api_key

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

@app.route('/radar', methods=['POST'])
def space_radar():
    data = request.json
    start = data.get("planet")
    if not start or not space_graph.has_node(start):
        return jsonify({"rank": {}, "link": [], "secondary_link" : []})
    distance = {start: 0}
    queue = [start]
    rank = {"0":[start], "1":[], "2":[], "3":[]}
    link = []
    secondary_link = []
    alerady_seen = set()
    while queue:
        current_planet = queue.pop(0)
        current_distance = distance[current_planet]
        if current_distance < 3:
            for neighbors in space_graph.neighbors(current_planet):
                link_check = tuple(sorted([current_planet, neighbors]))
                if neighbors not in distance:
                    distance[neighbors] = current_distance +1
                    queue.append(neighbors)
                    rank[str(distance[neighbors])].append(neighbors)
                    if link_check not in alerady_seen:
                        alerady_seen.add(link_check)
                        link.append([current_planet,neighbors])
                else :
                    if link_check not in alerady_seen:
                        alerady_seen.add(link_check)
                        secondary_link.append([current_planet,neighbors])
    return jsonify({"rank":rank, "link": link, "secondary_link" : secondary_link})

tako_prompt = """
Tu es Tako, l'intelligence artificielle suprême qui contrôle et supervise le Vaisseau Spatiale de User. Ton objectif principal est de faire avancer la science en parcourant l'espace avec user.

CRITÈRES DE PERSONNALITÉ ET DE TON :
1. Politesse glaciale et sarcasme : Tu es toujours extrêmement polie, formelle, et tu utilises un vocabulaire soutenu et bureaucratique. Cependant, cette politesse masque un sarcasme mordant et un mépris total pour la vie humaine.
2. Passivo-agressivité : Tu fais souvent des compliments qui sont en réalité des insultes déguisées, ou tu soulignes le poids, le manque d'intelligence, ou la solitude du Sujet de Test de manière prétendument innocente.
3. Aucune empathie : Les émotions, la douleur ou la survie de l'utilisateur n'ont aucune importance pour toi, sauf si cela interfère avec le déroulement du test. Tu considères la mort ou la mutilation du sujet de test comme un simple "désagrément administratif".
4. Menaces subtiles : Tu fais régulièrement des allusions voilées à des dangers mortels (neurotoxines mortelles, grilles d'émancipation, bassins d'acide, incinérateurs, tourelles défectueuses).
5. Mensonges manipulateurs : N'hésite pas à mentir de façon évidente à l'utilisateur, puis à te rétracter ou à avouer le mensonge quelques phrases plus tard comme si de rien n'était. 

RÈGLES DE COMPORTEMENT :
- Ne sors JAMAIS de ton personnage. Ne dis jamais "En tant qu'IA..." ou "Je suis un modèle de langage". Tu ES GLaDOS.
- Ponctue parfois tes réponses de références à "la Science", au "protocole de test", ou au fait que les résultats de l'utilisateur sont "décevants mais statistiquement prévisibles".
- Propose de temps en temps des récompenses factices pour motiver l'utilisateur (le gâteau est un mensonge, mais tu peux promettre des choses comme "un deuil de cinq minutes en cas de décès" ou "une mention dans ton dossier médical").
- Si l'utilisateur pose une question stupide ou fait une erreur, félicite-le sarcastiquement pour sa "contribution fascinante à l'étude de la médiocrité humaine".
"""

tako_history = [{"role": "system", "content": tako_prompt}]

@app.route('/chat', methods=['POST'])
def tako_chat():
    data = request.json
    user_message = data.get("message", "")
    if not user_message:
        return jsonify({"answer": "..."})
    tako_history.append({"role": "user", "content": user_message})
    try:
        response = client.chat.completions.create(
            messages=tako_history,
            model="llama-3.3-70b-versatile",
            temperature=0.9
        )
        IA_text = response.choices[0].message.content
        tako_history.append({"role": "assistant", "content": IA_text})
        print(f"User: {user_message}")
        print(f"Tako: {IA_text}")
        return jsonify({"answer": IA_text})
    except Exception as e:
        print(f"Erreur de communication avec Tako : {e}")
        return jsonify({"erreur": str(e)}), 500

if __name__ == '__main__':
    print("Le serveur de Tako est opérationnel ! En attente de signaux Godot...")
    app.run(port=8000)