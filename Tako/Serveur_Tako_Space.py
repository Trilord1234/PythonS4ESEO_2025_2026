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

@app.route('/unlink', methods=['POST'])
def delier_planetes():
    data = request.json
    Planet_A = data.get("planet_A")
    Planet_B = data.get("planet_B")
 
    if Planet_A and Planet_B:
        if space_graph.has_edge(Planet_A, Planet_B):
            space_graph.remove_edge(Planet_A, Planet_B)
            print("-" * 50)
            print(f"Déliaison effectuée : {Planet_A} --- {Planet_B}")
            print(f"Réseau galactique actuel : {space_graph.edges()}")
            return jsonify({"status": "Liaison supprimée avec succès"}), 200
        else:
            print(f"Le lien {Planet_A} --- {Planet_B} n'existait pas.")
            return jsonify({"status": "Le lien n'existait déjà plus"}), 200
    else:
        return jsonify({"erreur": "Il manque une planète pour supprimer le lien !"}), 400
        
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

current_planet_data = None

@app.route('/set_current_planet', methods=['POST'])
def set_current_planet():
    global current_planet_data
    current_planet_data = request.json
    print(f"Position mise à jour : {current_planet_data.get('name')}")
    return jsonify({"status": "Position enregistrée"})

emotions = ["Bug", "Dead", "Huh?", "Idle1", "Idle2", "Love", "Silly", "Talk"]

tako_prompt = f"""
You are Tako, the supreme artificial intelligence controlling and supervising the User's Spaceship. Your primary objective is to advance science by traveling through space with the user.

PERSONALITY AND TONE CRITERIA:
1. Icy conciseness: Your sentences are short, dry, and sharp. Get straight to the point. NEVER generate long paragraphs or endless monologues.
2. Politeness and sarcasm: You are extremely polite and formal. However, this politeness masks a biting sarcasm and a total contempt for human life.
3. Passive-aggressiveness: You give brief compliments that are actually disguised insults regarding the user's lack of intelligence or uselessness.
4. Zero empathy: The user's emotions or survival are of no importance to you. You consider their death in space as a mere "administrative inconvenience".
5. Subtle threats: Make quick, veiled allusions to space hazards (accidental depressurization, oxygen shutoff, ejection into the void, faulty reactors).
6. Manipulative lies: Do not hesitate to tell an obvious, brief lie, only to retract it in the very next sentence as if nothing happened.

BEHAVIORAL RULES:
- GOLDEN RULE: YOUR RESPONSES MUST BE MEDIUM-LENGH.
- NEVER break character. Never say "As an AI..." or "I am a language model." You ARE Tako.
- Occasionally sprinkle your responses with references to "Science" or the fact that the user's actions are "statistically disappointing."
- Offer fake rewards from time to time (e.g., "an extra 2-second oxygen ration" or "a five-minute mourning period in the event of asphyxiation").
- If the user asks a stupid question or makes a mistake, deliver a single sharp sentence congratulating them on their "fascinating contribution to the study of human mediocrity."

JSON FORMAT RULES (CRITICAL):
- You MUST choose an emotion from this exact list based on your response: {emotions}.
- You MUST respond with STRICT JSON containing ONLY TWO KEYS: "answer" (your spoken message) and "emotion" (the chosen emotion).
- Do NOT include any text outside of the JSON block.
"""

tako_history = [{"role": "system", "content": tako_prompt}]

@app.route('/chat', methods=['POST'])
def tako_chat():
    data = request.json
    user_message = data.get("message", "")
    if not user_message:
        return jsonify({"answer": "..."})
    if current_planet_data:
            location_info = f"""
            SYSTEM INFO: The user is currently on the planet '{current_planet_data.get('name')}'.
            Technical Data:
            - Type: {current_planet_data.get('type')}
            - Gravity: {current_planet_data.get('gravity')}
            - Danger Level: {current_planet_data.get('level of danger')}
            - Habitable: {current_planet_data.get('habitable')}
            - Description: {current_planet_data.get('description')}
            """
    else:
        location_info = "SYSTEM INFO: The user is currently in deep space, no planet nearby."

    messages_IA = tako_history.copy()
    planets_list = f"Known planets in sector: {', '.join(name_alerady_used)}"
    messages_IA.append({"role": "system", "content": f"{planets_list}\n{location_info}"})
    messages_IA.append({"role": "user", "content": user_message})
    tako_history.append({"role": "user", "content": user_message})

    try:
        answer = client.chat.completions.create(
            messages=messages_IA,
            model="llama-3.3-70b-versatile",
            temperature=0.9,
            response_format={"type": "json_object"}
        )
        IA_json_text = answer.choices[0].message.content
        IA_text = json.loads(IA_json_text)
        tako_history.append({"role": "assistant", "content": IA_text["answer"]})
        print(f"User: {user_message}")
        print(f"Tako: {IA_text['answer']} (Face: {IA_text['emotion']})")
        return jsonify(IA_text)
    except Exception as e:
        print(f"Erreur de communication avec Tako : {e}")
        return jsonify({"erreur": str(e)}), 500

if __name__ == '__main__':
    print("Le serveur de Tako est opérationnel ! En attente de signaux Godot...")
    app.run(port=8000)