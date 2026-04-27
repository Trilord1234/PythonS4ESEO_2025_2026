from flask import Flask, request, jsonify
import os
import sys
import json
from groq import Groq
from graph import Graph
from algorithms import dfs_path
app = Flask(__name__)

from TakoAPIKey import api_key_backup, api_key
client = Groq(api_key=api_key_backup) #or api_key

if getattr(sys, 'frozen', False):
    base_path = os.path.dirname(sys.executable)
else:
    base_path = os.path.dirname(os.path.abspath(__file__))
PATH_COMPLET = os.path.join(base_path, "graph_complet.json")
PATH_DECOUVERT = os.path.join(base_path, "graph_decouvert.json")

name_alerady_used = []
planet_db = {}

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
    visual_look = data.get("look", {})
    
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
            IA_dictionary["look"] = visual_look
            planet_db[planet] = IA_dictionary
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
    planet_db.clear()
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

@app.route('/hyperspeed_route', methods=['POST'])
def calculer_route_dfs():
    data = request.json
    start = data.get("start")
    end = data.get("end")
    if not start or not end:
        return jsonify({"erreur": "Coordonnées incomplètes"}), 400
    if not space_graph.has_node(start) or not space_graph.has_node(end):
        return jsonify({"erreur": "Planète inconnue dans le réseau"}), 404
    chemin = dfs_path(space_graph, start, end)
    if chemin:
        print(f"Saut Hyperspatial DFS calculé : {' -> '.join(chemin)}")
        return jsonify({"status": "success", "path": chemin})
    else:
        print(f"Aucune route possible entre {start} et {end}")
        return jsonify({"status": "no_path"}), 200

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

@app.route('/save_graph', methods=['POST'])
def save_graph_json():
    data = request.json
    scanned_planets = data.get("scanned_planets", [])
    
    def build_structured_data(mask_unknown=False):
        output = {}
        unknown_counter = 1
        name_map = {}
        
        for node in space_graph.nodes():
            if not mask_unknown or node in scanned_planets:
                name_map[node] = node
            else:
                name_map[node] = f"??? ({unknown_counter})"
                unknown_counter += 1
                
        for node in space_graph.nodes():
            real_name = node
            display_name = name_map[node]
            voisins_bruts = space_graph.neighbors(real_name)
            voisins_affiches = [name_map[v] for v in voisins_bruts]
            
            output[display_name] = {
                "voisins": voisins_affiches,
                "caractéristiques": {},
                "look": {}
            }
            
            if not mask_unknown or node in scanned_planets:
                infos = planet_db.get(real_name, {})
                output[display_name]["caractéristiques"] = {
                    "name": infos.get("name", real_name),
                    "type": infos.get("type", "Inconnu"),
                    "weight": infos.get("weight", "Inconnu"),
                    "size": infos.get("size", "Inconnu"),
                    "gravity": infos.get("gravity", "Inconnu"),
                    "habitable": infos.get("habitable", "Inconnu"),
                    "level of danger": infos.get("level of danger", "Inconnu"),
                    "description": infos.get("description", "Aucune description disponible.")
                }
                output[display_name]["look"] = infos.get("look", {
                    "planet": "unknown_texture",
                    "layer": "unknown_texture",
                    "planet_color": "#ffffff",
                    "layer_color": "#ffffff"
                })
            else:
                output[display_name]["caractéristiques"] = {
                    "status": "Données cryptées ou non scannées"
                }
                output[display_name]["look"] = {
                    "status": "Visuel non disponible"
                }
        return output
  
    full_graph = build_structured_data(mask_unknown=False)
    masked_graph = build_structured_data(mask_unknown=True)
    with open(PATH_COMPLET, "w", encoding="utf-8") as f:
        json.dump(full_graph, f, indent=4, ensure_ascii=False)   

    with open(PATH_DECOUVERT, "w", encoding="utf-8") as f:
        json.dump(masked_graph, f, indent=4, ensure_ascii=False) 

    print("Fichiers JSON générés avec succès !")
    return jsonify({"status": "Fichiers sauvegardés"})

@app.route('/get_graph', methods=['GET'])
def get_graph():
    global space_graph, planet_db, name_alerady_used
    try:
        if os.path.exists(PATH_COMPLET):
            with open(PATH_COMPLET, "r", encoding="utf-8") as f:
                data = json.load(f)
            space_graph = Graph()
            planet_db.clear()
            name_alerady_used.clear()
            for p_name, p_data in data.items():
                space_graph.add_node(p_name)
                name_alerady_used.append(p_name)
                db_entry = p_data.get("caractéristiques", {})
                db_entry["look"] = p_data.get("look", {})
                planet_db[p_name] = db_entry
                for voisin in p_data.get("voisins", []):
                    space_graph.add_node(voisin)
                    space_graph.add_edge(p_name, voisin)
            print("Mémoire du serveur restaurée depuis le JSON !")
            return jsonify(data)
        else:
            return jsonify({"erreur": "Aucun fichier de sauvegarde trouvé"}), 404
    except Exception as e:
        return jsonify({"erreur": str(e)}), 500

if __name__ == '__main__':
    print("Le serveur de Tako est opérationnel ! En attente de signaux Godot...")
    app.run(port=8000)