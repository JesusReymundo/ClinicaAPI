using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Seguro")]
public class Seguro
{
    [Key]
    public int IdSeguro { get; set; }
    [Required, MaxLength(100)]
    public string NombreSeguro { get; set; } = string.Empty;
    [MaxLength(50)]
    public string? TipoCobertura { get; set; }
    [MaxLength(200)]
    public string? Descripcion { get; set; }
    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;
    public DateTime? FechaModificacion { get; set; }
    public int? IdUsuarioCreacion { get; set; }
    public int? IdUsuarioModificacion { get; set; }
}
