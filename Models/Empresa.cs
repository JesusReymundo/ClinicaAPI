using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Empresa")]
public class Empresa
{
    [Key]
    public int IdEmpresa { get; set; }
    [Required, MaxLength(200)]
    public string RazonSocial { get; set; } = string.Empty;
    [Required, MaxLength(11)]
    public string RUC { get; set; } = string.Empty;
    [MaxLength(200)]
    public string? Direccion { get; set; }
    [MaxLength(20)]
    public string? Telefono { get; set; }
    [MaxLength(150)]
    public string? Email { get; set; }
    public bool Activo { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;
}
