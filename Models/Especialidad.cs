using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Especialidades")]
public class Especialidad
{
    [Key]
    public int IdEspecialidad { get; set; }
    [Required, MaxLength(100)]
    public string Nombre { get; set; } = string.Empty;
    [MaxLength(300)]
    public string? Descripcion { get; set; }
    public bool Activo { get; set; } = true;
}
