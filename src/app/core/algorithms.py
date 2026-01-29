"""
Module core.algorithms
-----------------------
Implémentation des algorithmes de parcours de graphes (DFS, BFS)
et résolution de problèmes classiques.

Paliers B, C, D.
"""

from collections import deque
from .graph import Graph


# ============================================================================
# PALIER B : DFS (Depth-First Search / Parcours en profondeur)
# ============================================================================

def dfs(graph: Graph, start: str) -> list[str]:
    """
    Parcours en profondeur (DFS) à partir d'un nœud de départ.
    
    Utilise une pile (implémentée avec une liste Python).
    Visite les voisins dans l'ordre alphabétique (grâce à graph.neighbors()).
    
    Args:
        graph: Le graphe à parcourir
        start: Le nœud de départ
    
    Returns:
        Liste des nœuds visités dans l'ordre du parcours DFS
    
    Raises:
        ValueError: Si le nœud de départ n'existe pas
    
    Exemple:
        >>> g = Graph()
        >>> g.add_edge("A", "B")
        >>> g.add_edge("A", "C")
        >>> g.add_edge("B", "D")
        >>> dfs(g, "A")
        ['A', 'B', 'D', 'C']  # Ordre déterministe car voisins triés alphabétiquement
    
    Note:
        ⚠️ CRITIQUE : Le résultat est déterministe car Graph.neighbors() retourne 
        une liste triée alphabétiquement. Ne pas modifier cet ordre !
    
    Algorithme:
        1. Créer une pile avec le nœud de départ
        2. Créer un ensemble de nœuds visités
        3. Tant que la pile n'est pas vide:
           - Dépiler un nœud
           - Si déjà visité, continuer
           - Marquer comme visité
           - Empiler tous ses voisins non visités
    """
    # TODO: implémenter DFS
    # Astuce : pile = list, visited = set

    if not graph.has_node(start):
        raise ValueError(f"Le noeud {start} n'existe pas")

    stack = [start]
    seen = set()
    

    while stack is True :
        current = stack.pop
        if current in seen:
            
            seen.add(current)
            result.append(current)
            voisins = graph.neighbors(current)

        for neighbors in (voisins):
            if neighbors not in seen:
                stack.append(neighbors)
    return(stack)






def dfs_path(graph: Graph, start: str, goal: str) -> list[str] | None:
    """
    Trouve un chemin entre deux nœuds avec DFS.
    
    Args:
        graph: Le graphe à parcourir
        start: Nœud de départ
        goal: Nœud cible
    
    Returns:
        Liste des nœuds du chemin (incluant start et goal)
        None si aucun chemin n'existe
    
    Exemple:
        >>> g = Graph()
        >>> g.add_edge("A", "B")
        >>> g.add_edge("B", "C")
        >>> dfs_path(g, "A", "C")
        ['A', 'B', 'C']
    
    Algorithme:
        Variante de DFS où on stocke le chemin complet dans la pile.
        Pile contient des tuples (nœud, chemin_jusqu'ici).
    """
    # TODO: implémenter
    # Astuce : pile contient (noeud, chemin) où chemin est une liste
    if not graph.has_node(start) or not graph.has_node(goal):
        return None
    stack = [(start, [start])]
    seen = set()

    while stack:
        current_node, path = stack.pop()
        if current_node == goal:
            return path
        if current_node in seen:
            continue
        seen.add(current_node)
        voisins = graph.neighbors(current_node)
        for neighbor in reversed(voisins):
            if neighbor not in seen:
                new_path = path + [neighbor]
                stack.append((neighbor, new_path))
    return None

    

# ============================================================================
# PALIER C : BFS (Breadth-First Search / Parcours en largeur)
# ============================================================================

def bfs(graph: Graph, start: str) -> list[str]:
    """
    Parcours en largeur (BFS) à partir d'un nœud de départ.
    
    Utilise une file (collections.deque).
    Explore le graphe couche par couche.
    
    Args:
        graph: Le graphe à parcourir
        start: Le nœud de départ
    
    Returns:
        Liste des nœuds visités dans l'ordre du parcours BFS
    
    Raises:
        ValueError: Si le nœud de départ n'existe pas
    
    Exemple:
        >>> g = Graph()
        >>> g.add_edge("A", "B")
        >>> g.add_edge("A", "C")
        >>> g.add_edge("B", "D")
        >>> bfs(g, "A")
        ['A', 'B', 'C', 'D']  # Ordre par couches
    
    Algorithme:
        1. Créer une file avec le nœud de départ
        2. Créer un ensemble de nœuds visités
        3. Tant que la file n'est pas vide:
           - Défiler un nœud
           - Marquer comme visité
           - Enfiler tous ses voisins non visités
    """
    # TODO: implémenter BFS
    # Astuce : file = deque(), visited = set
    pass


def bfs_path(graph: Graph, start: str, goal: str) -> list[str] | None:
    """
    Trouve le PLUS COURT chemin entre deux nœuds avec BFS.
    
    Args:
        graph: Le graphe à parcourir
        start: Nœud de départ
        goal: Nœud cible
    
    Returns:
        Liste des nœuds du plus court chemin (incluant start et goal)
        None si aucun chemin n'existe
    
    Note:
        BFS garantit de trouver le plus court chemin en nombre d'arêtes
        pour un graphe non pondéré.
    
    Exemple:
        >>> g = Graph()
        >>> g.add_edge("A", "B")
        >>> g.add_edge("B", "C")
        >>> g.add_edge("A", "C")  # Chemin direct plus court
        >>> bfs_path(g, "A", "C")
        ['A', 'C']
    
    Algorithme:
        Variante de BFS où on stocke le chemin complet dans la file.
        File contient des tuples (nœud, chemin_jusqu'ici).
    """
    # TODO: implémenter
    pass


# ============================================================================
# PALIER D : Problèmes classiques sur graphes
# ============================================================================

def is_connected(graph: Graph) -> bool:
    """
    Vérifie si le graphe est connexe.
    
    Un graphe est connexe si tous les nœuds sont atteignables
    depuis n'importe quel nœud.
    
    Args:
        graph: Le graphe à vérifier
    
    Returns:
        True si le graphe est connexe
        True si le graphe est vide (par convention mathématique)
        False si le graphe a plusieurs composantes connexes
    
    Exemple:
        >>> g = Graph()
        >>> g.add_edge("A", "B")
        >>> g.add_edge("C", "D")  # Deux composantes séparées
        >>> is_connected(g)
        False
        
        >>> g2 = Graph()  # Graphe vide
        >>> is_connected(g2)
        True  # Par convention (aucun nœud = connexe)
    
    Algorithme:
        1. Choisir un nœud de départ arbitraire
        2. Faire un parcours (DFS ou BFS) depuis ce nœud
        3. Vérifier si tous les nœuds ont été visités
    """
    # TODO: implémenter
    # Astuce : réutiliser dfs() ou bfs()
    pass


def reachable_from(graph: Graph, start: str) -> set[str]:
    """
    Retourne l'ensemble des nœuds atteignables depuis un nœud de départ.
    
    Args:
        graph: Le graphe à parcourir
        start: Nœud de départ
    
    Returns:
        Ensemble des nœuds atteignables (incluant start)
    
    Raises:
        ValueError: Si le nœud de départ n'existe pas
    
    Exemple:
        >>> g = Graph()
        >>> g.add_edge("A", "B")
        >>> g.add_edge("C", "D")
        >>> reachable_from(g, "A")
        {'A', 'B'}
    """
    # TODO: implémenter
    # Astuce : réutiliser dfs() et convertir en set
    pass


def shortest_path(graph: Graph, start: str, goal: str) -> list[str] | None:
    """
    Trouve le plus court chemin entre deux nœuds.
    
    Wrapper autour de bfs_path() pour plus de clarté sémantique.
    
    Args:
        graph: Le graphe à parcourir
        start: Nœud de départ
        goal: Nœud cible
    
    Returns:
        Liste des nœuds du plus court chemin
        None si aucun chemin n'existe
    
    Exemple:
        >>> g = Graph()
        >>> g.add_edge("A", "B")
        >>> g.add_edge("B", "C")
        >>> shortest_path(g, "A", "C")
        ['A', 'B', 'C']
    """
    # TODO: implémenter
    # Astuce : appeler bfs_path()
    pass


# ============================================================================
# Fonctions utilitaires (optionnel, mais utile pour debug)
# ============================================================================

def path_length(path: list[str] | None) -> int:
    """
    Retourne la longueur d'un chemin (nombre d'arêtes).
    
    Args:
        path: Liste de nœuds ou None
    
    Returns:
        Nombre d'arêtes (len(path) - 1), ou -1 si path est None
    """
    if path is None:
        return -1
    return len(path) - 1
