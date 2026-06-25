using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Rol")]
public class Rol
{
    [Key]
    public int IdRol { get; set; }
    [Required, MaxLength(50)]
    public string NombreRol { get; set; } = string.Empty;
    [MaxLength(200)]
    public string? Descripcion { get; set; }
    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;
}
