"""
Module core.io
--------------
Import/Export de graphes au format JSON.

Palier E.
"""

import json
from pathlib import Path
from .graph import Graph


# ============================================================================
# PALIER E : Import/Export
# ============================================================================

def save_graph(graph: Graph, filepath: str | Path) -> None:
    """
    Sauvegarde un graphe au format JSON.
    
    Format JSON:
    {
        "nodes": ["A", "B", "C"],
        "edges": [["A", "B"], ["B", "C"]]
    }
    
    Args:
        graph: Le graphe à sauvegarder
        filepath: Chemin du fichier de sortie
    
    Raises:
        IOError: Si l'écriture échoue
    
    Exemple:
        >>> g = Graph()
        >>> g.add_edge("A", "B")
        >>> save_graph(g, "my_graph.json")
    """
    data = graph_to_dict(graph)
    try:
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4)
    except IOError as e:
        raise IOError(f"Erreur lors de l'écriture dans le fichier {filepath}: {e}")


def load_graph(filepath: str | Path) -> Graph:
    """
    Charge un graphe depuis un fichier JSON.
    
    Format JSON attendu:
    {
        "nodes": ["A", "B", "C"],
        "edges": [["A", "B"], ["B", "C"]]
    }
    
    Args:
        filepath: Chemin du fichier à charger
    
    Returns:
        Le graphe chargé
    
    Raises:
        FileNotFoundError: Si le fichier n'existe pas
        ValueError: Si le format JSON est invalide
        KeyError: Si les clés "nodes" ou "edges" sont absentes
    
    Exemple:
        >>> g = load_graph("my_graph.json")
        >>> g.has_node("A")
        True
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        raise FileNotFoundError(f"Le fichier {filepath} n'existe pas.")
    except json.JSONDecodeError as e:
        raise ValueError(f"Le fichier JSON est invalide : {e}")
    return dict_to_graph(data)


def graph_to_dict(graph: Graph) -> dict:
    """
    Convertit un graphe en dictionnaire (utile pour serialization).
    
    Args:
        graph: Le graphe à convertir
    
    Returns:
        Dictionnaire avec clés "nodes" et "edges"
    
    Exemple:
        >>> g = Graph()
        >>> g.add_edge("A", "B")
        >>> graph_to_dict(g)
        {'nodes': ['A', 'B'], 'edges': [['A', 'B']]}
    """
    return {
        "nodes": list(graph.nodes()),
        "edges": [list(edge) for edge in graph.edges()]
    }


def dict_to_graph(data: dict) -> Graph:
    """
    Crée un graphe depuis un dictionnaire.
    
    Args:
        data: Dictionnaire avec clés "nodes" et "edges"
              - "nodes": liste de chaînes ["A", "B", "C"]
              - "edges": liste de paires [["A", "B"], ["B", "C"]]
                         (ou tuples : [("A", "B"), ("B", "C")])
    
    Returns:
        Le graphe créé
    
    Raises:
        KeyError: Si les clés requises sont absentes
        ValueError: Si le format est invalide (ex: arête invalide)
    
    Validation:
        - Clés "nodes" et "edges" doivent exister
        - "nodes" : liste de chaînes
        - "edges" : liste de paires [a, b] ou (a, b)
        - Chaque arête doit référencer des nœuds existants
    
    Exemple:
        >>> data = {'nodes': ['A', 'B'], 'edges': [['A', 'B']]}
        >>> g = dict_to_graph(data)
        >>> g.has_edge("A", "B")
        True
    """
    if "nodes" not in data or "edges" not in data:
        raise KeyError("Le dictionnaire doit contenir les clés 'nodes' et 'edges'.")
    nodes_data = data["nodes"]
    edges_data = data["edges"]
    if not isinstance(nodes_data, list):
        raise ValueError("La valeur associée à 'nodes' doit être une liste.")
    if not isinstance(edges_data, list):
        raise ValueError("La valeur associée à 'edges' doit être une liste.")
    g = Graph()
    for node in nodes_data:
        g.add_node(node)
    for edge in edges_data:
        if not isinstance(edge, (list, tuple)) or len(edge) != 2:
            raise ValueError(f"Format d'arête invalide : {edge}. Chaque arête doit être une liste ou un tuple de 2 éléments.")
        u, v = edge
        if u not in nodes_data or v not in nodes_data:
            raise ValueError(f"L'arête ({u}, {v}) référence des nœuds qui ne sont pas dans la liste des 'nodes'.")
        g.add_edge(u, v)
    return g
